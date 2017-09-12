#! /usr/bin/python

##################################
# Downloads BNA input data
# and runs analysis without
# starting up a VM. Instead
# takes an existing target DB as
# input.
#
# Requires the following software
# on the local machine:
#   -osm2pgsql
#   -osm2pgrouting
#   -shp2pgsql
#   -postgresql client libraries (psql)
##################################
import os
import subprocess
import sys
import argparse

def main(argv):
    parser = argparse.ArgumentParser(description='Downloads BNA input data \
    and runs analysis without \
    starting up a VM. Instead \
    takes an existing target DB as \
    input. \
     \
    Requires the following software \
    on the local machine: \
      -osm2pgsql \
      -osm2pgrouting \
      -shp2pgsql \
      -postgresql client libraries (psql)')
    parser.add_argument('-H','--host',dest='dbhost',help='Host address')
    parser.add_argument('-d','--database',dest='db',help='Host database')
    parser.add_argument('-U','--user',dest='dbuser',help='Database username')
    parser.add_argument('-p','--password',dest='dbpass',help='Database password')
    parser.add_argument('-o','--osmfile',dest='osmfile',help='OSM input file')
    parser.add_argument('nbshp',help='Neighborhood boundary shapefile')
    parser.add_argument('state_abbrev',help='Two letter state abbreviation')
    parser.add_argument('state_fips',help='Two digit state FIPS code')
    parser.add_argument('-v',dest='verbose',action='store_true',help='Verbose mode')
    args = parser.parse_args()

    # set vars
    verbose = args.verbose
    if verbose:
        print(' ')
    dbHost = args.dbhost
    db = args.db
    dbUser = args.dbuser
    dbPass = args.dbpass
    osmFile = args.osmfile


if __name__ == "__main__":
    main(sys.argv[1:])
