FROM quay.io/azavea/postgis:latest
MAINTAINER Azavea

RUN apt-get update && apt-get install -y unzip postgis \
        expat libexpat1-dev cmake libboost-all-dev make \
        g++ zlib1g-dev libbz2-dev libpq-dev libgeos-dev \
        libgeos++-dev libproj-dev lua5.2 liblua5.2-dev \
        git wget bc time parallel \
        postgresql-server-dev-$PG_MAJOR \
        postgresql-plpython-$PG_MAJOR \
        postgresql-$PG_MAJOR-pgrouting

COPY ./ /pfb/

RUN /pfb/build_tools.sh

ENTRYPOINT /pfb/entrypoint.sh
