# Note: the Django and psycopg2 versions are repeated in requirements.txt for the benefit
# of the analysis container. The base container and requirements file versions should be kept
# in sync.
FROM python:3.10-slim-bullseye

WORKDIR /usr/src
COPY requirements.txt /tmp/

RUN set -ex \
    && buildDeps=" \
       build-essential \
       libpq-dev \
    " \
    && deps=" \
       gdal-bin \
       libgdal-dev \
       gettext \
       postgresql-client-13 \
    " \
    && apt-get update && apt-get install -y $buildDeps $deps --no-install-recommends \
    && pip install --no-cache-dir -r /tmp/requirements.txt \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -rf /tmp/requirements.txt /var/lib/apt/lists/*

COPY . /usr/src

EXPOSE 9202

ENTRYPOINT ["/usr/local/bin/gunicorn"]
