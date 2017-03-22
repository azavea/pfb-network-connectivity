# Running the Analysis Locally

### Setup

All commands should be run inside the VM from the `/vagrant/` directory.

The container is built by `scripts/update`, but can be rebuilt by running:
```
pushd pfb-analysis
docker build -t pfb-analysis .
popd
```

### Example

To run the analysis for Boulder, CO:
```
./scripts/run-local-analysis https://s3.amazonaws.com/test-pfb-inputs/boulder/boulder.zip co 08
```

This will take up to an hour, so just let it work. Consider piping script output to a file and
running in a screen/tmux session.

#### Using local files

The analysis can also gets its input data from local files.  To run the analysis using the
same Boulder boundary and a pre-downloaded OSM file, download
[the zipped shapefile](https://s3.amazonaws.com/test-pfb-inputs/boulder/boulder.zip)
and extract it to `./data/`.
Also download [the OSM file](https://s3.amazonaws.com/test-pfb-inputs/boulder/boulder-osm.zip)
and extract it into `./data/`.

Then run:
```
PFB_OSM_FILE=/data/boulder.osm ./scripts/run-local-analysis /data/boulder.shp co 08
```

### Analysis parameters

See the usage message of `scripts/run-local-analysis` for all options and defaults, but
here's a table of the environment variables that can be set to affect the analyis:

| Variable | Purpose | Default value |
| -------- | ------- | ------------- |
| NB_INPUT_SRID | SRID of the input shapefile | 4326 |
| NB_MAX_TRIP_DISTANCE | The maximum trip distance (in meters) considered in the connectivity calculations. | 3300 |
| NB_BOUNDARY_BUFFER | The distance (in meters) beyond the edge of the boundary given by the shapefile to include in the imported geographic data. | 1/2 * NB_MAX_TRIP_DISTANCE |
| PFB_OSM_FILE | An exported OSM file to use instead of downloading current OSM data during the analysis | |
| PFB_OSM_FILE_URL | A URL from which a zipped .osm file can be downloaded. Overrides PFB_OSM_FILE. | none |
| NB_OUTPUT_DIR | The path, within the analysis container, to write results to. The directory will be created (if possible) if it doesn't exist. | /data/output |
| AWS_STORAGE_BUCKET_NAME | The S3 bucket to upload results to. Requires `AWS_PROFILE` be set. | {DEV_USER}-pfb-storage-us-east-1 |
| AWS_PROFILE | The name of the AWS profile, configured in `~/.aws` to use for uploading to S3. | pfb |
| PFB_JOB_ID | The job ID of the analysis job, which isn't really applicable when directly running a local analysis but which is required because it's used in the results upload path. | 'local-job-YYYY-MM-DD-HHMM' |


### Running other neighborhoods

The following input files are also available at https://s3.amazonaws.com/test-pfb-inputs/.

- Cambridge, MA
    - Shapefile: https://s3.amazonaws.com/test-pfb-inputs/cambridge/neighborhood_boundary_02138.zip
    - OSM files: https://s3.amazonaws.com/test-pfb-inputs/cambridge/cambridge-osm.zip
    - FIPS code: 25
    - set `NB_INPUT_SRID=2249`
- Lower Manhattan, NY
    - Shapefile: https://s3.amazonaws.com/test-pfb-inputs/lowermanhattan/lowermanhattan.zip
    - OSM file: https://s3.amazonaws.com/test-pfb-inputs/lowermanhattan/lowermanhattan-osm.zip
    - FIPS code: 36
    - A large network.  Analysis is lengthy and resource-intensive.
- Center City Philadelphia, PA
    - Shapefile: https://s3.amazonaws.com/test-pfb-inputs/philly/philly.zip
    - OSM file: https://s3.amazonaws.com/test-pfb-inputs/philly/philly-osm.zip
    - FIPS code: 42
- Germantown, PA
    - Shapefile: https://s3.amazonaws.com/test-pfb-inputs/germantown/gtown_westside.zip
    - OSM file: https://s3.amazonaws.com/test-pfb-inputs/germantown/gtown_westside-osm.zip
    - FIPS code: 42
    - A small area for quick tests

### Cleaning up old analysis runs

Each analysis run takes up a significant amount of limited VM disk space. To clear old analysis volumes once finished with them, run:
```
./scripts/clean-analysis-volumes
```
