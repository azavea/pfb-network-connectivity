#!/usr/bin/env python3

"""
A script to cache Census LODES data on S3 to avoid downloading the same file repeatedly.

Given a local directory, a state, and an S3 bucket, it
- Checks first if the LODES file is already in the local directory, and does nothing if so
- Tries to download the LODES file for the state and data type from the S3 bucket
- If it's not there, tries to download the file from the Census site and upload it to the S3 bucket
- It it's not found, tries to download the file from the previous year from S3 and then from Census

If run without a state defined, it will run for all states, deleting each local download as it goes
(so as to not overwhelm the local disk space). This option exists to build the S3 cache.

If run without a data type defined, it will run for both data types.
(This option is only expected to be run in conjunction with no set state, to build the S3 cache.)
"""
import argparse
import gzip
import logging
import os
import shutil
import sys

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

LODES_DATA_TYPES = ('main', 'aux')
# fall back to an older year if the most recent in use is not available
LODES_MOST_RECENT_YEAR = '2017'
LODES_FALLBACK_YEAR = '2016'
LODES_URL = 'http://lehd.ces.census.gov/data/lodes/LODES7'
S3_LODES_DIRECTORY = 'data/'
STATE_ABBREVIATIONS = [state.abbr.lower() for state in us.STATES]


try:
    S3_CLIENT = boto3.client('s3')
except ProfileNotFound:
    logger.warn('No AWS profile found to use for the Census LODES data cache on S3')
    S3_CLIENT = None


def build_lodes_path(state_abbrev, data_type, year):
    """
    Returns the file path for the Census site download, which is also the local file name
    and the key used for the S3 cache.
    """
    return '{state}_od_{data_type}_JT00_{year}.csv.gz'.format(state=state_abbrev,
                                                              data_type=data_type,
                                                              year=year)


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


def download_from_census(local_path, state, filename):
    """ Returns true if the LODES file is successfully downloaded from the Census site. """
    url = '{url}/{state}/od/{filename}'.format(url=LODES_URL, state=state, filename=filename)

    logger.debug('Going to download LODES file from {}...'.format(url))

    with requests.get(url, allow_redirects=True) as req:
        if not req.ok:
            return False
        with open(local_path, 'wb') as local_file:
            local_file.write(req.content)

    logger.debug('Downloaded LODES file {} from Census Bureau site'.format(filename))
    return True


def download_from_s3(local_path, filename, bucket_name=None, check_only=False):
    """
    Returns true if the LODES file `filename` is successfully found in the S3 cache.

    If `check_only` is false, this will also download the file locally to `local_path`.
    """
    s3_path = '{s3_lodes_dir}/{filename}'.format(s3_lodes_dir=S3_LODES_DIRECTORY, filename=filename)
    if not S3_CLIENT or not bucket_name or not check_s3(bucket_name, s3_path):
        return False

    if check_only:
        return True

    boto3.s3.transfer.S3Transfer(S3_CLIENT).download_file(bucket_name, s3_path, local_path)
    logger.debug('Downloaded cached LODES file {} from S3'.format(filename))
    return True


def upload_to_s3(local_path, filename, bucket_name=None):
    if not S3_CLIENT or not bucket_name:
        return False

    s3_path = '{s3_lodes_dir}/{filename}'.format(s3_lodes_dir=S3_LODES_DIRECTORY, filename=filename)
    boto3.s3.transfer.S3Transfer(S3_CLIENT).upload_file(local_path, bucket_name, s3_path)
    logger.info('Uploaded LODES file {} to S3 cache'.format(filename))


def process_download(state, data_type, local_dir, bucket=None, check_only=False):
    """
    Returns local file path if file successfully downloaded.

    Will do nothing if file already exists in the local file cache.
    Attempts to download first from the S3 cache, then from the Census site,
    first for the most recent LODES year in use, then for the backup year.
    Census site downloads are uploaded to the S3 cache if not there already.

    If `check_only` is true, it will only check if the file is on S3 but not download it from there
    (for use to build the S3 cache).
    """
    logger.debug('Processing LODES request for state {state} and data type {data_type}'.format(
                 state=state, data_type=data_type))
    filename = build_lodes_path(state, data_type, LODES_MOST_RECENT_YEAR)
    local_path = os.path.join(local_dir, filename)

    if os.path.exists(local_path.strip('.gz')):
        logger.debug('LODES file {} already cached locally; skipping download'.format(filename))
        # Do not return the file path, as there is no need to extract or delete the zipped file
        return ''

    if download_from_s3(local_path, filename, bucket, check_only):
        logger.debug('Found cached LODES file {} on S3'.format(filename))
        return '' if check_only else local_path

    logger.debug('Cached LODES file {} not found on S3; check Census'.format(filename))
    if download_from_census(local_path, state, filename):
        upload_to_s3(local_path, filename, bucket)
        return local_path

    logger.debug('LODES file {} not found on Census site; try fallback year'.format(filename))
    filename = build_lodes_path(state, data_type, LODES_FALLBACK_YEAR)
    if download_from_s3(local_path, filename, bucket, check_only):
        logger.debug('Found cached LODES file {} for backup year on S3'.format(filename))
        return '' if check_only else local_path

    logger.debug('Cached LODES file {} for backup year not on S3; check Census'.format(filename))
    if download_from_census(local_path, state, filename):
        upload_to_s3(local_path, filename, bucket)
        return local_path

    # Should not get this far
    logger.warn(''.join(('Could not find LODES file for state {state} and data type {data_type} ',
                         'for either year on S3 or Census site')).format(
                state=state, data_type=data_type))
    return ''


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--local-dir", default=None,
                        help="The directory to put downloaded LODES files in")
    parser.add_argument("--state-abbrev", default=None, help="state abbreviation")
    parser.add_argument("--data-type", default=None, choices=LODES_DATA_TYPES,
                        help="data type (main or aux)")
    parser.add_argument("--storage-bucket", default=None, help="S3 storage bucket")
    parser.add_argument('--verbose', '-v', action="store_true")
    args = parser.parse_args()

    local_dir = args.local_dir if args.local_dir else os.getenv('NB_DATA_DIR')
    bucket = args.storage_bucket if args.storage_bucket else os.getenv('AWS_STORAGE_BUCKET_NAME')
    if args.verbose or os.getenv('PFB_DEBUG'):
        logger.setLevel('DEBUG')
    else:
        logger.setLevel('INFO')

    if args.state_abbrev and args.state_abbrev.lower() in STATE_ABBREVIATIONS:
        states = (args.state_abbrev.lower(),)
    else:
        # If no state provided, download all
        logger.info('Running LODES download for all states.')
        states = STATE_ABBREVIATIONS

    # If running the script for all states, do not actually download files for S3,
    # only check if it is present.
    check_only = len(states) > 1

    # Use both data types if none specified
    data_types = (args.data_type,) if args.data_type else LODES_DATA_TYPES

    for state in states:
        for data_type in data_types:
            local_file = ''
            try:
                local_file = process_download(state, data_type, local_dir, bucket, check_only)
            except ClientError as e:
                # Handle general S3 errors, such as lack of permissions
                logger.exception('Failed to process LODES file for S3 bucket {bucket}'.format(
                                 bucket=bucket))
                logger.exception(e)
                # Do not attempt to continue processing other files (if any)
                return

            if local_file:
                # Unzip the downloaded CSV file if using it for procssing.
                # (Running this script for all states should only be done to build the S3 cache.)
                if not check_only:
                    with gzip.open(local_file, 'rb') as gzip_file:
                        with open(local_file.strip('.gz'), 'wb') as out_file:
                            shutil.copyfileobj(gzip_file, out_file)

                os.remove(local_file)

            print(local_file.strip('.gz'))

    return


main()
