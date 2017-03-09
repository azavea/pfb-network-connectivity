# pfb-network-connectivity

PFB Bicycle Network Connectivity

## Getting Started

Requirements:
- Vagrant 1.8+
- VirtualBox 4.3+
- [AWS CLI](https://aws.amazon.com/cli/)

#### Notes for Windows users

1. Ensure all project files checkout with LF (unix) line endings. The easiest way is to run `git config --global core.autocrlf false` before checking out the project. Alternatively, you can checkout the project, then run `git config core.autocrlf false` within the project dir, then manually fix all remaining CRLF line endings before running `vagrant up`.
2. Run all commands in a shell with administrator permissions. It's highly recommended to run all commands within the "Git for Windows" Git Bash shell, as that already includes an SSH client, and allows running the commands below as-is.
3. Before starting the VM, ensure the ENV variable `PFB_SHARED_FOLDER_TYPE=virtualbox` is set. NFS is not supported on windows, so we need to ensure that Vagrant ignores our request for it.
4. Do not use `vagrant reload`. In some cases it will create a new VM rather than autodetecting that the old one exists

### Setting up AWS credentials

As noted above, ensure the AWS CLI is installed on your host machine. Once it is, you can configure your PFB account credentials by running:
```
aws configure --profile pfb
```

If you do not have AWS credentials, this step can be skipped but some application services may not
work as intended.

### Provisioning the VM

First you'll need to copy the example ansible group_vars file:
```
cp deployment/ansible/group_vars/all.example deployment/group_vars/all
```
If you have access to the AWS console, copy the appropriate values at the links below into `deployment/ansible/group_vars/all`, choosing the resources with 'staging' in the name:
- [AWS Batch Compute Environments](https://console.aws.amazon.com/batch/home?region=us-east-1#/compute-environments): The value in "Compute environment ARN" to `pfb_aws_batch_compute_environment_arn`
- [AWS Batch Job Queues](https://console.aws.amazon.com/batch/home?region=us-east-1#/queues): The value in "Job queue name" to `pfb_aws_batch_job_queue_arn`
If you don't have access to the console, copying the values into `group_vars/all` can be skipped. Like above, some features of the application may fail unexpectedly.

Run `./scripts/setup` to install project dependencies and prepare the development environment. Then, SSH into the VM:
```
vagrant ssh
```

At this point, if you only intend to run the 'Bike Network Analysis', skip directly to [Running the Analysis](#running-the-analysis)

To start the application containers:
```
./scripts/server
```

In order to use the API, you'll need to run migrations on the Django app server:
```
./scripts/django-manage migrate

This will add a default admin user that can log in to http://localhost:9200/api/ as:
systems+pfb@azavea.com / root
```


## Ports

| Port | Service | Notes |
| ---- | ------- | ----- |
| 9200 | Nginx ||
| 9202 | Gunicorn ||
| 9203 | Django Runserver | Not running by default. Must be started manually via `scripts/django-manage` |
| 9214 | Postgresql | Allows direct connections to the database where an analysis run is stored |
| 9301 | Gulp | Gulp server for analysis angular app |
| 9302 | Browsersync | Browsersync for analysis angular app |


## Scripts

| Name | Description |
| ---- | ----------- |
| setup | Bring up a dev VM, and perform initial installation steps |
| update | Re-build application Docker containers and run database migrations |
| server | Start the application containers |
| console | Start a bash shell on one of the running Docker containers |
| django-manage | Run a Django management command on the django container |


## Running the Analysis

Copy the 'neighborhood_boundary_02138.zip' file on fileshare and unzip to `./data/neighborhood_boundary.shp`.

In this example, we configure the analysis to be run for Cambridge MA.

Run:
```
pushd pfb-analysis
docker build -t pfb-analysis .
popd

docker run \
    -e PFB_SHPFILE=/data/neighborhood_boundary.shp \
    -e PFB_STATE=ma \
    -e PFB_STATE_FIPS=25 \
    -e NB_INPUT_SRID=2249 \
    -e NB_BOUNDARY_BUFFER=3600 \
    -v /vagrant/data/:/data/ \
    pfb-analysis
```

This will take up to 1hr, so just let it work. Consider piping script output to a file and running in
a screen/tmux session.

#### Re-running the analysis

If you want to run a different neighborhood, simply rerun the `docker run` command with the
appropriate arguments, which are described below, in [Importing other neighborhoods](#importing-other-neighborhoods).

#### Cleaning up old analysis runs

Each analysis run takes up a significant amount of limited VM disk space. To clear old analysis volumes once finished with them, run:
```
./scripts/clean-analysis-volumes
```


## Importing other neighborhoods

Running the analysis requires a neighborhood shapefile polygon to run the analysis against.

To get started, place your neighborhood boundary shapefile, unzipped, in the project `./data` directory.

You will also need to know the following:
- State abbrev that your neighborhood is found in, e.g. 'ma' for Massachussetts
- State FIPS code that your neighborhood is found in: https://www.census.gov/geo/reference/ansi_statetables.html
- SRID of your neighborhood boundary file (input)
- SRID you want to run the analysis in (output)

Now run:
```
docker run \
    -e PFB_SHPFILE=<path_to_boundary_shp> \
    -e PFB_STATE=<state abbrev> \
    -e PFB_STATE_FIPS=<state fips> \
    -e NB_INPUT_SRID=<input srid> \
    -e NB_BOUNDARY_BUFFER=<buffer distance in meters> \
    -v /vagrant/data/:/data/ \
    pfb-analysis
```


## Verifying the Analysis

The output from the analysis run may be compared to previous output to see if it has changed. See the section below for the input parameters used to generate the verified output.

Build the docker container for the verification tool within the VM:
```
cd src/verifier
docker-compose build
```

Ensure the exported output from the analysis to check exists in the `data/output` directory. It will be there by default if the `data` directory was used for the neighborhood input shapefile.

To compare the analysis output for Boulder, run the verification tool with:
```
docker-compose run verifier boulder.csv
```

Any output in the `verified_output` directory may be used for comparison.

To compare to analysis output that has a non-default filename (`analysis_neighborhood_overall_scores.csv`), run the verification tool with the name of the file in `data/output` as the second argument:
```
docker-compose run verifier boulder.csv my_output_to_verify.csv
```

If there are any differences in the outputs, a summary of the differences will be output to console.


## Verified Output Parameters

The analysis output in the `verified_output` directory was generated using the following input parameters and files:

Boulder:
- BOUNDARY_BUFFER=50
- https://s3.amazonaws.com/test-pfb-inputs/boulder/boulder.osm
- https://s3.amazonaws.com/test-pfb-inputs/boulder/boulder.zip
