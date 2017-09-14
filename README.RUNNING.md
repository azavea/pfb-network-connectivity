# Running the Analysis Locally

### Setup

Local analysis depends on having the following software installed on the
local machine:
* [psql](https://www.postgresql.org/) (PostgreSQL client libraries)
* [osm2pgsql](https://github.com/openstreetmap/osm2pgsql)
* [osm2pgrouting](https://github.com/pgRouting/osm2pgrouting)
* [shp2pgsql](http://postgis.net/docs/manual-2.3/using_postgis_dbmanagement.html#shp2pgsql_usage) (part of the PostGIS project)

In addition, a local analysis depends on having the following extensions
installed on the target database:
* [PostGIS](http://postgis.net/)
* [pgRouting](http://pgrouting.org/)
* [quantile](https://github.com/tvondra/quantile)


### Simple example

To run the analysis for Boulder, CO:
```
./scripts/run-local-analysis.py /path/to/boulder.shp co 08
```

This will take up to an hour, so just let it work. Consider piping script output to a file and
running in a screen/tmux session.

### Command line options

Help for the local analysis can be read from the command line with the -h flag
```
run-local-analysis.py -h
```
Here's a table of the command line options that can be set to affect the analyis:

| Option | Purpose | Default value |
| -------- | ------- | ------------- |
| -h/--help | Display help and exit | - |
| -H/--host | Host address | 127.0.0.1 (localhost) |
| -d/--database | Host database name | pfb |
| -U/--user | Database username | pfb |
| -p/--password | Database password | pfb |
| --insrid | SRID of input neighborhood boundary | 4326 |
| --outsrid | SRID to be used in the analysis | 2163 |
| -o/--osmfile | Path to the OSM input file | - |
| -c/--connectivity | Only run the connectivity calculations | - |
| -i/--import | Only run the data import | - |
| -v | Verbose mode | - |
