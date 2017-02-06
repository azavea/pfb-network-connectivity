#!/bin/bash

set -e

cd /tmp/

# osm2pgrouting

git clone --branch 'osm2pgrouting-2.1.0' https://github.com/pgRouting/osm2pgrouting.git

pushd osm2pgrouting
  mkdir build
  cmake -H. -Bbuild
  pushd build
    make
    make install
  popd
popd

# osm2pgsql

git clone --branch '0.90.1' https://github.com/openstreetmap/osm2pgsql.git

pushd osm2pgsql
  mkdir build
  pushd build
    cmake ../
    make
    make install
  popd
popd

# quantile

git clone --branch master https://github.com/tvondra/quantile.git

pushd quantile
  make install
popd

git clone --branch nodes https://github.com/spencerrecneps/TDG-Tools.git

# TDG tools

pushd TDG-Tools
  pushd TDG\ SQL\ Tools
    make clean
    make install
  popd
popd
