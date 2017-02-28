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

Run `./scripts/setup` to install project dependencies and prepare the development environment. Then, SSH into the VM:
```
vagrant ssh
```

At this point, if you only intend to run the 'Bike Network Analysis', skip directly to [Running the Analysis](#running-the-analysis)

To start the application containers:
```
./scripts/server
```

In order to use the API, you'll need to create a superuser in development by following the prompts:
```
./scripts/django-manage createsuperuser
```


## Ports

| Port | Service | Notes |
| ---- | ------- | ----- |
| 9200 | Nginx ||
| 9202 | Gunicorn ||
| 9203 | Django Runserver | Not running by default. Must be started manually via `scripts/django-manage` |
| 9210 | Webpack | Runs Angular webpack dev server |
| 9211 | LiveReload | Angular webpack dev server live reload |
| 9212 | Webpack | Runs Angular webpack prod server. Not running by default. Must start manually via `./scripts/console` |
| 9213 | LiveReload | Angular webpack prod server live reload |
| 9214 | Postgresql | Allows direct connections to the database where an analysis run is stored |


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
docker build -t pfb .
popd

docker run \
    -e PFB_SHPFILE=/data/neighborhood_boundary.shp \
    -e PFB_STATE=ma \
    -e PFB_STATE_FIPS=25 \
    -e NB_INPUT_SRID=2249 \
    -e NB_BOUNDARY_BUFFER=11000 \
    -v /vagrant/data/:/data/ \
    pfb
```

This will take up to 1hr, so just let it work. Consider piping script output to a file and running in
a screen/tmux session.

#### Re-running the analysis

If you want to run a different neighborhood, simply rerun the `docker run` command with the
appropriate arguments, which are described below, in [Importing other neighborhoods](#importing-other-neighborhoods).


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
    -e NB_BOUNDARY_BUFFER=<buffer distance in units of NB_OUTPUT_SRID> \
    -v /vagrant/data/:/data/ \
    pfb
```
