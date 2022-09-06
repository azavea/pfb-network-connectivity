FROM postgis/postgis:13-3.1
MAINTAINER Azavea
LABEL type=pfb-analysis

# Copy django requirements (will copy the rest later, so that any change to
# the code doesn't trigger re-running the whole provisioning step)
COPY ./django/requirements.txt /opt/pfb/django/requirements.txt

# Install apt and pip packages
# Installs everything then removes the build dependencies all in one gigantic command to
# avoid making a build layer that includes the dependencies that we don't need to keep permanently.
# The 'hash -r' after upgrading pip is because otherwise the subsequent 'pip install' command will
# still use the old version.
RUN set -xe && \
    BUILD_DEPS=" \
        postgresql-server-dev-$PG_MAJOR \
        postgresql-server-dev-13 \
        libexpat1-dev \
        cmake \
        libboost-all-dev make \
        g++ \
        zlib1g-dev \
        libbz2-dev \
        libpq-dev \
        libgeos-dev \
        libgeos++-dev \
        libproj-dev \
        libgdal-dev \
        git" \
    DEPS=" \
        ca-certificates \
        liblua5.2-dev \
        lua5.2 \
        expat \
        wget \
        bc \
        time \
        parallel \
        postgresql-plpython3-$PG_MAJOR \
        postgresql-$PG_MAJOR-pgrouting \
        python3-gdal \
        gdal-bin \
        unzip \
        zip \
        postgis \
        python3 \
        python3-dev \
        python3-pip \
        osm2pgrouting \
        osm2pgsql" && \
    apt-get update && apt-get install -y ${BUILD_DEPS} ${DEPS} --no-install-recommends && \
    \
    mkdir /tmp/build/ && cd /tmp/build && \
    git clone --branch master https://github.com/tvondra/quantile.git && \
      (cd quantile && make install) && \
    \
    pip3 install --upgrade pip setuptools && \
    hash -r && \
    pip3 install -r /opt/pfb/django/requirements.txt && \
    \
    cd /tmp/ && rm -rf /tmp/build/ /var/lib/apt/lists/* && \
    apt-get purge -y --auto-remove ${BUILD_DEPS}

RUN set -xe && \
    wget -q "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" && \
    unzip awscli-exe-linux-x86_64.zip && \
    ./aws/install && \
    rm -r ./aws*

RUN set -xe && \
    wget -q -O /usr/local/bin/osmconvert "https://s3.amazonaws.com/pfb-binaries-us-east-1/osmconvert64" && \
    chmod +x /usr/local/bin/osmconvert

COPY ./django /opt/pfb/django

COPY ./analysis/scripts/setup_database.sh /docker-entrypoint-initdb.d/setup_database.sh
COPY ./analysis/ /opt/pfb/analysis/

ENTRYPOINT /opt/pfb/analysis/scripts/entrypoint.sh
