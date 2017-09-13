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
    parser.add_argument('-H','--host',dest='dbhost',default='127.0.0.1',help='Host address (default: 127.0.0.1)')
    parser.add_argument('-d','--database',dest='db',default='pfb',help='Host database (default: pfb)')
    parser.add_argument('-U','--user',dest='dbuser',default='pfb',help='Database username (default: pfb)')
    parser.add_argument('-p','--password',dest='dbpass',default='pfb',help='Database password (default: pfb)')
    parser.add_argument('--insrid',dest='insrid',default='4326',help='SRID of input neighborhood boundary (default: 4326)')
    parser.add_argument('--outsrid',dest='outsrid',default='2163',help='SRID to be used in the analysis (default: 2163)')
    parser.add_argument('-o','--osmfile',dest='osmfile',help='OSM input file')
    parser.add_argument('nbshp',help='Neighborhood boundary shapefile')
    parser.add_argument('state_abbrev',help='Two letter state abbreviation')
    parser.add_argument('state_fips',help='Two digit state FIPS code')
    parser.add_argument('-v',dest='verbose',action='store_true',help='Verbose mode')
    args = parser.parse_args()

    # get script dir location
    scriptsPath = os.path.join(os.path.dirname(os.path.realpath(__file__)),'../src/analysis/scripts')

    # set vars
    verbose = args.verbose
    if verbose:
        print(' ')
    dbHost = args.dbhost
    db = args.db
    dbUser = args.dbuser
    dbPass = args.dbpass
    inSrid = args.insrid
    outSrid = args.outsrid
    if args.osmfile is not None:
        osmFile = os.path.abspath(args.osmfile)
    nbShape = os.path.abspath(args.nbshp)
    stateAbbrev = args.state_abbrev
    stateFips = args.state_fips

    # set bash environment
    os.environ['NB_POSTGRESQL_HOST'] = dbHost
    os.environ['NB_POSTGRESQL_DB'] = db
    os.environ['NB_POSTGRESQL_USER'] = dbUser
    os.environ['NB_POSTGRESQL_PASSWORD'] = dbPass
    os.environ['NB_INPUT_SRID'] = inSrid
    os.environ['NB_OUTPUT_SRID'] = outSrid
    if osmFile is not None:
        os.environ['PFB_OSM_FILE'] = osmFile
    os.environ['PFB_LOCAL'] = '1'

    # import
    subprocess.call([os.path.join(scriptsPath,'import.sh'),nbShape,stateAbbrev,stateFips])

if __name__ == "__main__":
    main(sys.argv[1:])
