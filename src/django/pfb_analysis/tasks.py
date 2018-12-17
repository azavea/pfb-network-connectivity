import logging
import os
import shutil
import tempfile
import zipfile

import boto3

from django.conf import settings
from django.core.exceptions import ObjectDoesNotExist, ValidationError

from pfb_analysis.models import AnalysisBatch, AnalysisJob, AnalysisLocalUploadTask
from pfb_network_connectivity.utils import download_file
from users.models import PFBUser

logger = logging.getLogger(__name__)

LOCAL_ANALYSIS_FILES = set((
    'neighborhood_census_blocks.geojson',
    'neighborhood_census_blocks.zip',
    'neighborhood_colleges.geojson',
    'neighborhood_community_centers.geojson',
    'neighborhood_connected_census_blocks.csv.zip',
    'neighborhood_dentists.geojson',
    'neighborhood_doctors.geojson',
    'neighborhood_hospitals.geojson',
    'neighborhood_overall_scores.csv',
    'neighborhood_parks.geojson',
    'neighborhood_pharmacies.geojson',
    'neighborhood_retail.geojson',
    'neighborhood_schools.geojson',
    'neighborhood_score_inputs.csv',
    'neighborhood_social_services.geojson',
    'neighborhood_supermarkets.geojson',
    'neighborhood_transit.geojson',
    'neighborhood_universities.geojson',
    'neighborhood_ways.zip',
))


def create_batch_from_remote_shapefile(shapefile_url):

    tmpdir = tempfile.mkdtemp()
    try:
        local_filename = os.path.join(tmpdir, 'shapefile.zip')
        download_file(shapefile_url, local_filename=local_filename)
        user = PFBUser.objects.get_root_user()
        batch = AnalysisBatch.objects.create_from_shapefile(local_filename, submit=False, user=user)
        batch.submit()
    finally:
        shutil.rmtree(tmpdir)


def upload_local_analysis(local_upload_task_uuid):
    logging.info('Starting local analysis upload task {uuid}'.format(uuid=local_upload_task_uuid))

    try:
        task = AnalysisLocalUploadTask.objects.get(uuid=local_upload_task_uuid)
    except (ObjectDoesNotExist, ValidationError):
        logging.error('No local upload analysis task found for {uuid}.'.format(
                      uuid=local_upload_task_uuid))
        return

    task.status = AnalysisLocalUploadTask.Status.IMPORTING
    task.save()

    logging.info('Starting local analysis upload {uuid} from {url}'.format(
                 uuid=local_upload_task_uuid, url=task.upload_results_url))

    # Download and extract zipfile of results from provided URL
    tmpdir = tempfile.mkdtemp()
    try:
        local_filename = os.path.join(tmpdir, 'analysis_results.zip')
        download_file(task.upload_results_url, local_filename=local_filename)
        with zipfile.ZipFile(local_filename, 'r') as zip_handle:
            zip_handle.extractall(tmpdir)
        results_files = [filename for filename in os.listdir(tmpdir)]
        for rfile in results_files:
            logging.info('Extracted results file: {rfile}'.format(rfile=rfile))
        missing = LOCAL_ANALYSIS_FILES.difference(set(results_files))
        if missing:
            logging.error('Missing expected results files for task {uuid}: {files}'.format(
                          uuid=local_upload_task_uuid,
                          files=', '.join(missing)))
            task.status = AnalysisLocalUploadTask.Status.ERROR
            task.error = 'Missing expected results files: {files}'.format(files=', '.join(missing))
            task.save()
            shutil.rmtree(tmpdir)
            return
    except Exception as ex:
        logging.error('Failed to fetch analysis results for task {uuid} from {url}: {msg}'.format(
                      uuid=local_upload_task_uuid,
                      url=task.upload_results_url,
                      msg=ex.message))
        task.status = AnalysisLocalUploadTask.Status.ERROR
        task.error = ex.message
        task.save()
        shutil.rmtree(tmpdir)
        return

    # If we got this far, the expected results files have been extracted successfully
    logging.info('Results files extracted for upload task {uuid}'.format(
                 uuid=local_upload_task_uuid))

    s3_client = boto3.client('s3')

    # upload to the expected S3 locations for the job

    # Upload the geojson files
    for d in task.job.destinations_urls:
        dest_url = d['url']
        path, filename = os.path.split(dest_url)
        s3_key = '{results_path}/{filename}'.format(results_path=task.job.s3_results_path,
                                                    filename=filename)
        local_file = os.path.join(tmpdir, filename)
        s3_client.upload_file(local_file, settings.AWS_STORAGE_BUCKET_NAME, s3_key)
        logging.info('Uploaded results file {s3_key}'.format(s3_key=s3_key))

    # Mark this upload task and its associated analysis job as completed.
    task.job.status = AnalysisJob.Status.COMPLETE
    task.job.save()
    task.status = AnalysisLocalUploadTask.Status.COMPLETE
    task.save()
    logging.info('Successfully completed upload task {uuid}'.format(uuid=local_upload_task_uuid))
