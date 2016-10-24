# pfb-network-connectivity

PFB Bicycle Network Connectivity


## Getting Started

Run './script/setup'

### Loading OSM Data and Preparing the Network

Copy files from FILESHARE and extract into `./data`:
- cambridge.osm.gz
- neighborhood_boundary_02138.zip

Prepare to run the analysis by executing the following within the VM:
```
# Load neighborhood data
NB_INPUT_SRID=2249 NB_OUTPUT_SRID=2249 ./pfb-analysis/import_neighborhood.sh data/neighborhood_boundary.shp 25

# Load jobs data
./pfb-analysis/import_jobs.sh ma

# Load OSM data
./pfb-analysis/import_osm.sh

# Create network
psql -h 127.0.0.1 -U gis -d pfb -c "SELECT tdgMakeNetwork('cambridge_ways');"
psql -h 127.0.0.1 -U gis -d pfb -c "SELECT tdgNetworkCostFromDistance('cambridge_ways');"

```

The database should now be ready for [Running the Analysis](#running-the-analysis)

NOTE: If you want to run the analysis on a different boundary, simply re-run the above steps
using the appropriate inputs to the scripts, rather than the pre-defined ones above.


## Running the Analysis

Run `./pfb-analysis/run_connectivity.sh`

This will take ~2.5hrs, so just let it work. Consider piping script output to a file and running in
a screen/tmux session.


## Next Steps

Performance issues. `./pfb-analysis/run_connectivity.sh` takes ~2.5hrs to run on my VM. It is possible
we could gain significant boosts from additional indices, tweaking of postgresql.conf, and query
rewriting to improve the execution plan. If none of that works, we'd have to rewrite the analysis
with some other language.

The scripts in the `pfb-analysis` directory are not generally well parameterized. If we want to
run an area other than cambridge, we should rename the tables to not include the area being run.
