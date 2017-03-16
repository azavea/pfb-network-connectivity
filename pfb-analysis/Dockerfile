FROM quay.io/azavea/postgis:postgres9.6-postgis2.3
MAINTAINER Azavea
LABEL type=pfb-analysis

ENV GIT_BRANCH_OSM2PGROUTING osm2pgrouting-2.1.0
ENV GIT_BRANCH_OSM2PGSQL 0.90.1
ENV GIT_BRANCH_QUANTILE master

# Copy in the django app
COPY ./src/django /opt/pfb/django

RUN set -xe && \
    BUILD_DEPS=" \
        postgresql-server-dev-$PG_MAJOR \
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
        git \
        python-dev \
        python-pip" \
    DEPS=" \
        ca-certificates \
        liblua5.2-dev \
        lua5.2 \
        expat \
        wget \
        bc \
        time \
        parallel \
        postgresql-plpython-$PG_MAJOR \
        postgresql-$PG_MAJOR-pgrouting \
        python-gdal \
        unzip \
        zip \
        postgis" && \
    apt-get update && apt-get install -y ${BUILD_DEPS} ${DEPS} --no-install-recommends && \
    \
    mkdir /tmp/build/ && cd /tmp/build && \
      git clone --branch $GIT_BRANCH_OSM2PGROUTING https://github.com/pgRouting/osm2pgrouting.git && \
        (cd osm2pgrouting && mkdir build && cmake -H. -Bbuild && cd build && make install) && \
      git clone --branch $GIT_BRANCH_OSM2PGSQL https://github.com/openstreetmap/osm2pgsql.git && \
        (cd osm2pgsql && mkdir build && cd build && cmake ../ && make install) && \
      git clone --branch $GIT_BRANCH_QUANTILE https://github.com/tvondra/quantile.git && \
        (cd quantile && make install) && \
    \
    pip install -r /opt/pfb/django/requirements.txt && \
    \
    cd /tmp/ && rm -rf /tmp/build/ /var/lib/apt/lists/* && \
    apt-get purge -y --auto-remove ${BUILD_DEPS}

RUN set -xe && \
    wget -q "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" && \
    unzip awscli-bundle.zip && \
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
    rm -r ./awscli-bundle*

COPY ./pfb-analysis/scripts/setup_database.sh /docker-entrypoint-initdb.d/setup_database.sh
COPY ./pfb-analysis/ /opt/pfb/analysis/

ENTRYPOINT /opt/pfb/analysis/scripts/entrypoint.sh
