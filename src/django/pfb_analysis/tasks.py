import logging
import os
import shutil
import tempfile

from pfb_analysis.models import AnalysisBatch
from pfb_network_connectivity.utils import download_file
from users.models import PFBUser

logger = logging.getLogger(__name__)


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
    logging.warn('TODO: upload local analysis for task {uuid}'.format(uuid=local_upload_task_uuid))
