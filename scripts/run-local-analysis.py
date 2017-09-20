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
#   -psycopg2
##################################
import os
import subprocess
import sys
import argparse
import psycopg2
from psycopg2.extensions import AsIs

def showFipsCodes():
    table = [
        ["State","Abbrev","FIPS"],
        ["------------------","------","----"],
        ["Alabama","AL","01"],
        ["Alaska","AK","02"],
        ["Arizona","AZ","04"],
        ["Arkansas","AR","05"],
        ["California","CA","06"],
        ["Colorado","CO","08"],
        ["Connecticut","CT","09"],
        ["Delaware","DE","10"],
        ["District of Columbia","DC","11"],
        ["Florida","FL","12"],
        ["Georgia","GA","13"],
        ["Hawaii","HI","15"],
        ["Idaho","ID","16"],
        ["Illinois","IL","17"],
        ["Indiana","IN","18"],
        ["Iowa","IA","19"],
        ["Kansas","KS","20"],
        ["Kentucky","KY","21"],
        ["Louisiana","LA","22"],
        ["Maine","ME","23"],
        ["Maryland","MD","24"],
        ["Massachusetts","MA","25"],
        ["Michigan","MI","26"],
        ["Minnesota","MN","27"],
        ["Mississippi","MS","28"],
        ["Missouri","MO","29"],
        ["Montana","MT","30"],
        ["Nebraska","NE","31"],
        ["Nevada","NV","32"],
        ["New Hampshire","NH","33"],
        ["New Jersey","NJ","34"],
        ["New Mexico","NM","35"],
        ["New York","NY","36"],
        ["North Carolina","NC","37"],
        ["North Dakota","ND","38"],
        ["Ohio","OH","39"],
        ["Oklahoma","OK","40"],
        ["Oregon","OR","41"],
        ["Pennsylvania","PA","42"],
        ["Rhode Island","RI","44"],
        ["South Carolina","SC","45"],
        ["South Dakota","SD","46"],
        ["Tennessee","TN","47"],
        ["Texas","TX","48"],
        ["Utah","UT","49"],
        ["Vermont","VT","50"],
        ["Virginia","VA","51"],
        ["Washington","WA","53"],
        ["West Virginia","WV","54"],
        ["Wisconsin","WI","55"],
        ["Wyoming","WY","56"]
    ]
    widths = [max(map(len, col)) for col in zip(*table)]
    for row in table:
        print "  ".join((val.ljust(width) for val, width in zip(row, widths)))

def isDbExtension(conn,extName):
    '''
    Tests the database at the given conn for whether the extension given
    in extName is activated.
    '''
    try:
        cur = conn.cursor()
        cur.execute("select 1 from pg_extension where extname=%s;", [extName])
        return (cur.rowcount > 0)
    except psycopg2.Error as e:
        raise Exception(e)
    finally:
        cur.close()

def isExecutable(execName):
    '''
    Tests the local machine for the existence of the named executable
    in the execution path.
    '''
    isExe = False
    for path in os.environ["PATH"].split(os.pathsep):
        path = path.strip('"')
        exe_file = os.path.join(path, execName)
        isExe = isExe or (os.path.isfile(exe_file) and os.access(exe_file, os.X_OK))
    return isExe

def main(argv):
    localExecutables = ["psql","osm2pgsql","osm2pgrouting","shp2pgsql"]
    pgExtensions = ["postgis","pgrouting","quantile"]
    parser = argparse.ArgumentParser(
        description='Downloads BNA input data and runs analysis without \
        starting up a VM. Instead takes an existing target DB as input. \
        Requires the following software on the local machine: \
          osm2pgsql \
          osm2pgrouting \
          shp2pgsql \
          psql (postgresql client libraries)',
        usage='Use run-local-analysis.py -h for all options'
    )
    parser.add_argument('--fips',dest='fips',action='store_true',default=False,help='Display FIPS codes and exit')
    parser.add_argument('-H','--host',dest='dbhost',default='127.0.0.1',help='Host address (default: 127.0.0.1)')
    parser.add_argument('-d','--database',dest='dbname',default='pfb',help='Host database name (default: pfb)')
    parser.add_argument('-U','--user',dest='dbuser',default='pfb',help='Database username (default: pfb)')
    parser.add_argument('-p','--password',dest='dbpass',default='pfb',help='Database password (default: pfb)')
    parser.add_argument('--insrid',dest='insrid',default='4326',help='SRID of input neighborhood boundary (default: 4326)')
    parser.add_argument('--outsrid',dest='outsrid',default='2163',help='SRID to be used in the analysis (default: 2163)')
    parser.add_argument('-o','--osmfile',dest='osmfile',help='OSM input file')
    parser.add_argument('-c','--connectivity',dest='onlyconn',action="store_true",default=False,help='Only run the connectivity calculations')
    parser.add_argument('-i','--import',dest='onlyimport',action="store_true",default=False,help='Only run the data import')
    parser.add_argument('nbshp',help='Neighborhood boundary shapefile')
    parser.add_argument('state_abbrev',help='Two letter state abbreviation')
    parser.add_argument('state_fips',help='Two digit state FIPS code')
    parser.add_argument('-v',dest='verbose',action='store_true',help='Verbose mode')
    # need to check for fips option before parsing the rest
    if "--fips" in sys.argv:
        showFipsCodes()
        sys.exit(0)
    args = parser.parse_args()

    # get scripts dir location
    scriptsPath = os.path.join(os.path.dirname(os.path.realpath(__file__)),'../src/analysis/scripts')

    # set vars
    verbose = args.verbose
    if verbose:
        print(' ')
    dbHost = args.dbhost
    dbName = args.dbname
    dbUser = args.dbuser
    dbPass = args.dbpass
    inSrid = args.insrid
    outSrid = args.outsrid
    if args.osmfile:
        osmFile = os.path.abspath(args.osmfile)
    onlyConn = args.onlyconn
    onlyImport = args.onlyimport
    nbShape = os.path.abspath(args.nbshp)
    stateAbbrev = args.state_abbrev
    stateFips = args.state_fips

    # test for necessary local executables
    for exe in localExecutables:
        if not isExecutable(exe):
            raise Exception("Could not find %s. Please install or reconfigure." % exe)

    # test for db existence
    try:
        conn = psycopg2.connect("host=%s dbname=%s user=%s password=%s" % (dbHost,dbName,dbUser,dbPass))
    except psycopg2.Error as e:
        #print("\nCould not connect to database at \nhost: %s\nname: %s\nuser: %s\npassword: %s" % (dbHost,dbName,dbUser,dbPass))
        raise Exception(e)

    # test for necessary db extensions
    for ext in pgExtensions:
        if not isDbExtension(conn, ext):
            raise Exception("Extension \"%s\" not enabled in database" % ext)

    # create schemas
    cur = conn.cursor()
    for schema in ['generated','received','scratch']:
        cur.execute("create schema if not exists \"%s\" authorization %s;",[AsIs(schema),AsIs(dbUser)])
    conn.commit()
    cur.close()
    conn.close()

    # set bash environment
    os.environ['NB_POSTGRESQL_HOST'] = dbHost
    os.environ['NB_POSTGRESQL_DB'] = dbName
    os.environ['NB_POSTGRESQL_USER'] = dbUser
    os.environ['NB_POSTGRESQL_PASSWORD'] = dbPass
    os.environ['NB_INPUT_SRID'] = inSrid
    os.environ['NB_OUTPUT_SRID'] = outSrid
    if args.osmfile:
        os.environ['PFB_OSM_FILE'] = osmFile
    os.environ['PFB_LOCAL'] = '1'

    # import
    if not onlyConn:
        subprocess.call([os.path.join(scriptsPath,'import.sh'),nbShape,stateAbbrev,stateFips])
    if not onlyImport:
        subprocess.call([os.path.join(scriptsPath,'run_connectivity.sh')])

if __name__ == "__main__":
    main(sys.argv[1:])
