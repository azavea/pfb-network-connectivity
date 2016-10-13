# pfb-network-connectivity

PFB Bicycle Network Connectivity


## Getting Started

Run './script/setup'

### Loading OSM Data and Preparing the Network

Copy files from FILESHARE and extract into `./data`:
- cambridge.osm.gz

Download and install each of the datasets in [Importing Related Data](#importing-related-data).

Open `./pfb-analysis/import-osm.sh` and update vars in header, then run it.

Before running the analysis, it is necessary to create the network. Do so with:
```
psql -h 127.0.0.1 -U gis -d pfb -c "SELECT tdgMakeNetwork('cambridge_ways');"
psql -h 127.0.0.1 -U gis -d pfb -c "SELECT tdgNetworkCostFromDistance('cambridge_ways');"
```

The database should now be ready for [Running the Analysis](#running-the-analysis)


## Running the Analysis

Run `./pfb-analysis/run_connectivity.sh`

This will take ~12hrs, so just let it work. Consider piping script output to a file and running in
a screen/tmux session.


## Next Steps

Massive performance issues. `./pfb-analysis/run_connectivity.sh` takes ~13hrs to run on my VM. It is possible
we could gain significant boosts from additional indices, tweaking of postgresql.conf, and query
rewriting to improve the execution plan. If none of that works, we'd have to rewrite the analysis
with some other language.

The scripts in the `pfb-analysis` directory are not generally well parameterized. If we want to
run an area other than cambridge, we should rename the tables to not include the area being run,
and also parametrize the zip code 'neighborhood' area to run the analysis on. It is currently
hardcoded to 02138.


## Importing Related Data

#### Census Blocks

Download from: http://www2.census.gov/geo/tiger/TIGER2010BLKPOPHU/tabblock2010_25_pophu.zip or
copy from fileshare.

Import with: `shp2pgsql -s 4326:2249 ./data/tabblock2010_25_pophu cambridge_census_blocks | psql -U gis -d pfb`


#### Zip Codes

Download from: https://www2.census.gov/geo/tiger/TIGER2016/ZCTA5/tl_2016_us_zcta510.zip

Import with: `shp2pgsql -s 4326:2249 ./data/tl_2016_us_zcta510 cambridge_zip_codes | psql -U gis -d pfb`
Fixup column name with: `psql -U gis -d pfb -c 'ALTER TABLE cambridge_zip_codes RENAME COLUMN zcta5ce10 TO zip_code;'`


#### Census Jobs Data

Download:
 - http://lehd.ces.census.gov/data/lodes/LODES7/ma/od/ma_od_main_JT00_2014.csv.gz
 - http://lehd.ces.census.gov/data/lodes/LODES7/ma/od/ma_od_aux_JT00_2014.csv.gz

Create Tables:
```
CREATE TABLE IF NOT EXISTS "ma_od_main_JT00_2014" (
    w_geocode varchar(15),
    h_geocode varchar(15),
    "S000" integer,
    "SA01" integer,
    "SA02" integer,
    "SA03" integer,
    "SE01" integer,
    "SE02" integer,
    "SE03" integer,
    "SI01" integer,
    "SI02" integer,
    "SI03" integer,
    createdate VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS "ma_od_aux_JT00_2014" (
    w_geocode varchar(15),
    h_geocode varchar(15),
    "S000" integer,
    "SA01" integer,
    "SA02" integer,
    "SA03" integer,
    "SE01" integer,
    "SE02" integer,
    "SE03" integer,
    "SI01" integer,
    "SI02" integer,
    "SI03" integer,
    createdate VARCHAR(32)
);

```

Import Tables:
```
psql -U gis -d pfb
> TRUNCATE TABLE "ma_od_main_JT00_2014";
> TRUNCATE TABLE "ma_od_aux_JT00_2014";
> COPY "ma_od_main_JT00_2014"(w_geocode, h_geocode, "S000", "SA01", "SA02", "SA03", "SE01", "SE02", "SE03", "SI01", "SI02", "SI03", createdate) FROM '/vagrant/data/ma_od_main_JT00_2014.csv' DELIMITER ',' CSV HEADER;
> COPY "ma_od_aux_JT00_2014"(w_geocode, h_geocode, "S000", "SA01", "SA02", "SA03", "SE01", "SE02", "SE03", "SI01", "SI02", "SI03", createdate) FROM '/vagrant/data/ma_od_aux_JT00_2014.csv' DELIMITER ',' CSV HEADER;
```
