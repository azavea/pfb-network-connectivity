#!/usr/bin/env python3

"""
A script to cache Census block shapefiles on S3 to avoid downloading the same file repeatedly.

Given a local directory, a state, and an S3 bucket, it
- Checks first if the block shapefile is already in the local directory, and does nothing if so
- Tries to download the block shapefile for the state from the S3 bucket
- If it's not there, tries to download the file from the Census site and upload it to the S3 bucket

If run without a state defined, it will run for all states, deleting each local download as it goes
(so as to not overwhelm the local disk space). This option exists to build the S3 cache.
"""
import argparse
import logging
import os
import sys
import zipfile

import boto3
from botocore.exceptions import ClientError
from botocore.exceptions import ProfileNotFound
import requests
import us

logging.basicConfig(
    stream=sys.stderr,
    format='{} %(asctime)s %(levelname)-8s %(message)s'.format(os.path.basename(__file__)),
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__file__)

BLOCK_URL = 'http://www2.census.gov/geo/tiger/TIGER2010BLKPOPHU'
S3_CACHE_DIRECTORY = 'data'
STATE_FIPS = [state.fips for state in us.STATES]


try:
    S3_CLIENT = boto3.client('s3')
except ProfileNotFound:
    logger.warn('No AWS profile found to use for the Census data cache on S3')
    S3_CLIENT = None


def build_block_path(state_fips):
    """
    Returns the file path for the Census site download, which is also the local file name
    and the key used for the S3 cache.
    """
    return 'tabblock2010_{state_fips}_pophu.zip'.format(state_fips=state_fips)


def check_s3(bucket_name, s3_path):
    """ Returns true if a key exists at the given path on S3. """
    try:
        S3_CLIENT.head_object(Bucket=bucket_name, Key=s3_path)
        return True
    except ClientError as e:
        # Check if not found (an expected case)
        if e.response['Error']['Code'] == '404':
            return False
        else:
            raise e


def download_from_census(local_path, filename):
    """ Returns true if the block shapefile is successfully downloaded from the Census site. """
    url = '{url}/{filename}'.format(url=BLOCK_URL, filename=filename)

    logger.debug('Going to download Census block file from {}...'.format(url))

    with requests.get(url, allow_redirects=True) as req:
        if not req.ok:
            return False
        with open(local_path, 'wb') as local_file:
            local_file.write(req.content)

    logger.debug('Downloaded block file {} from Census Bureau site'.format(filename))
    return True


def download_from_s3(local_path, filename, bucket_name=None, check_only=False):
    """
    Returns true if the block shapefile `filename` is successfully found in the S3 cache.

    If `check_only` is false, this will also download the file locally to `local_path`.
    """
    s3_path = '{s3_cache_dir}/{filename}'.format(s3_cache_dir=S3_CACHE_DIRECTORY, filename=filename)
    if not S3_CLIENT or not bucket_name or not check_s3(bucket_name, s3_path):
        return False

    if check_only:
        return True

    boto3.s3.transfer.S3Transfer(S3_CLIENT).download_file(bucket_name, s3_path, local_path)
    logger.debug('Downloaded cached Census block shapefile {} from S3'.format(filename))
    return True


def upload_to_s3(local_path, filename, bucket_name=None):
    if not S3_CLIENT or not bucket_name:
        return False

    s3_path = '{s3_cache_dir}/{filename}'.format(s3_cache_dir=S3_CACHE_DIRECTORY, filename=filename)
    boto3.s3.transfer.S3Transfer(S3_CLIENT).upload_file(local_path, bucket_name, s3_path)
    logger.info('Uploaded Censs block shapefile {} to S3 cache'.format(filename))


def process_download(state_fips, local_dir, bucket=None, check_only=False):
    """
    Returns local file path if file successfully downloaded.

    Will do nothing if file already exists in the local file cache.
    Attempts to download first from the S3 cache, then from the Census site.
    Census site downloads are uploaded to the S3 cache if not there already.

    If `check_only` is true, it will only check if the file is on S3 but not download it from there
    (for use to build the S3 cache).
    """
    logger.debug('Processing Census block shapefile request for state FIPS {}'.format(state_fips))
    filename = build_block_path(state_fips)
    local_path = os.path.join(local_dir, filename)

    if os.path.exists(local_path.strip('.zip') + '.shp'):
        logger.debug('Block file {} already cached locally; skipping download'.format(filename))
        # Do not return the file path, as there is no need to extract or delete the zipped file
        return ''

    if download_from_s3(local_path, filename, bucket, check_only):
        logger.debug('Found cached Census block shapefile {} on S3'.format(filename))
        return '' if check_only else local_path

    logger.debug('Cached Census shapefile {} not found on S3; check Census'.format(filename))
    if download_from_census(local_path, filename):
        upload_to_s3(local_path, filename, bucket)
        return local_path

    # Should not get this far
    logger.warn('Could not find Census block shapefile for state FIPS {} on Census site').format(
        state_fips)
    return ''


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--local-dir", default=None,
                        help="The directory to put downloaded Census block shapefiles in")
    parser.add_argument("--state-fips", default=None, help="state FIPS code")
    parser.add_argument("--storage-bucket", default=None, help="S3 storage bucket")
    parser.add_argument('--verbose', '-v', action="store_true")
    args = parser.parse_args()

    local_dir = args.local_dir if args.local_dir else os.getenv('NB_DATA_DIR')
    bucket = args.storage_bucket if args.storage_bucket else os.getenv('AWS_STORAGE_BUCKET_NAME')
    if args.verbose or os.getenv('PFB_DEBUG'):
        logger.setLevel('DEBUG')
    else:
        logger.setLevel('INFO')

    if args.state_fips in STATE_FIPS:
        fips_codes = (args.state_fips,)
    else:
        # If no state provided, download all
        logger.info('Running Census block shapefile download for all states.')
        fips_codes = STATE_FIPS

    # If running the script for all states, do not actually download files for S3,
    # only check if it is present.
    check_only = len(fips_codes) > 1

    for fips in fips_codes:
        local_file = ''
        try:
            local_file = process_download(fips, local_dir, bucket, check_only)
        except ClientError as e:
            # Handle general S3 errors, such as lack of permissions
            logger.exception('Failed to process Census block file for S3 bucket {bucket}'.format(
                             bucket=bucket))
            logger.exception(e)
            # Do not attempt to continue processing other files (if any)
            return

        if local_file:
            # Unzip the downloaded shapefile if using it for procssing, then delete the zipped file.
            # (Running this script for all states should only be done to build the S3 cache.)
            if not check_only:
                with zipfile.ZipFile(local_file, 'rb') as zip_file:
                    zip_file.extractall(local_dir)

            os.remove(local_file)

        print(local_file.strip('.zip') + '.shp')

    return


main()
