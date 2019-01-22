import os

import requests


def download_file(url, local_filename=None):
    if not local_filename:
        local_filename = os.path.join('.', url.split('/')[-1])
    r = requests.get(url, stream=True)
    with open(local_filename, 'wb') as f:
        for chunk in r.iter_content(chunk_size=1024):
            if chunk:  # filter out keep-alive new chunks
                f.write(chunk)
    return local_filename
