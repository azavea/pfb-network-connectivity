# pfb-network-connectivity

PFB Bicycle Network Connectivity

## Getting Started

Requirements:

- [Docker Compose](https://docs.docker.com/compose/install/)
- [AWS CLI](https://aws.amazon.com/cli/)

### Setting up AWS credentials and reating your development S3 bucket

Though the development environment runs locally for the most part, some functions require an S3 bucket.  The deployment scripts also expect an AWS profile called 'pfb' to be configured.

As noted above, you will need to have the AWS CLI installed on your host machine. Once it is, you can configure your PFB account credentials by running:
```
aws configure --profile pfb
```

Then run the following commands to create and configure your development S3 bucket:
```
export AWS_PROFILE=pfb
export PFB_DEV_BUCKET="${USER}-pfb-storage-us-east-1"
aws s3api create-bucket --bucket $PFB_DEV_BUCKET
aws s3api put-bucket-policy --bucket $PFB_DEV_BUCKET --policy "{\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::${PFB_DEV_BUCKET}/*\"}]}"
aws s3api put-bucket-cors --bucket $PFB_DEV_BUCKET --cors-configuration "{\"CORSRules\":[{\"AllowedHeaders\":[\"Authorization\"],\"AllowedMethods\":[\"GET\"],\"AllowedOrigins\":[\"*\"],\"ExposeHeaders\":[],\"MaxAgeSeconds\":3000}]}"
```

### Provisioning the development environment

Run `./scripts/setup` to build the containers and prepare the development environment. This includes downloading and loading a fixture containing sample neighborhood and analysis data. To build the containers but skip loading the fixture, run `./scripts/update` instead.

### Running the development server

To start the application containers, run:
```
./scripts/server
```

The development server can be found at http://localhost:9301/.

The migrations that get run by `scripts/update` will add a default admin user:
```
Username: systems+pfb@azavea.com
Password: root
```

These credentials will work to log in to either the front-end admin (http://localhost:9301/#/login/) or the Django Rest Framework development interface (http://localhost:9200/api/).


## Ports

| Port | Service          | Notes                                                                        |
| ---- | ---------------- | ---------------------------------------------------------------------------- |
| 9200 | Nginx            |                                                                              |
| 9202 | Gunicorn         |                                                                              |
| 9203 | Django Runserver | Not running by default. Must be started manually via `scripts/django-manage` |
| 9214 | Postgresql       | Allows direct connections to the database where an analysis run is stored    |
| 9301 | Gulp             | Gulp server for analysis angular app                                         |
| 9302 | Browsersync      | Browsersync for analysis angular app                                         |
| 9400 | Tilegarden       | Tilegarden development server                                                |
| 9401 | Browsersync      | Node debugger for Tilegarden development server                              |

## Scripts

| Name          | Description                                                        |
| ------------- | ------------------------------------------------------------------ |
| setup         | Build application containers and import data fixture               |
| update        | Re-build application Docker containers and run database migrations |
| server        | Start the application containers                                   |
| console       | Start a bash shell on one of the running Docker containers         |
| django-manage | Run a Django management command on the django container            |
| test          | Run unit tests and linters                                         |
| cibuild       | Deployment script for building and testing container images        |
| cipublish     | Deployment script for publishing container images to AWS ECR       |
| infra         | Deployment script for deploying infrastructure on AWS              |

## Running the Analysis

Local environments are not hooked up to Batch to run the analysis, so when you create a job locally, it doesn't automatically get run.  Instead, when you create anaylsis job in the local admin UI, the logs for the Django container will print the appropriate command to run that analysis job locally, so you can just copy the command from there and run it. Look for the log message that says

> [WARNING] Can't actually run development analysis jobs on AWS. Try this:

and copy the command right below it.

For more details on the parameters used by the script, and other ways of running the analysis, see [Running the Analysis Locally](README.LOCAL-ANALYSIS.md).

## Verifying the Analysis

The output from the analysis run may be compared to previous output to see if it has changed. See the section below for the input parameters used to generate the verified output.

Build the docker container for the verification tool:

```
cd src/verifier
docker compose build
```

Ensure the exported output from the analysis to check exists in the `data/output` directory. It will be there by default if the `data` directory was used for the neighborhood input shapefile.

To compare the analysis output for Boulder, run the verification tool with:

```
docker compose run verifier boulder.csv
```

Any output in the `verified_output` directory may be used for comparison.

To compare to analysis output that has a non-default filename (`analysis_neighborhood_score_inputs.csv`), run the verification tool with the name of the file in `data/output` as the second argument:

```
docker compose run verifier boulder.csv my_output_to_verify.csv
```

If there are any differences in the outputs, a summary of the differences will be printed to the console.

### Verified Output Parameters

The analysis output in the `verified_output` directory was generated using the following input parameters and files:

Boulder:

- BOUNDARY_BUFFER=50
- https://s3.amazonaws.com/test-pfb-inputs/boulder/boulder.osm
- https://s3.amazonaws.com/test-pfb-inputs/boulder/boulder.zip

## Import crash data

Crash data is stored in the `pfb-public-documents` bucket under `/data/crashes.zip` and gets loaded automatically via `scripts/update`. You can run this import manually with:
`./scripts/django-manage import_crash_data`

To run it using a zip in your own developer bucket under `/data/crashes.zip` you can use the `--dev` flag, i.e.
`./scripts/django-manage import_crash_data --dev`
