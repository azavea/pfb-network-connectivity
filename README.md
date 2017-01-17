# pfb-network-connectivity

PFB Bicycle Network Connectivity

## Getting Started

Requirements:
- Vagrant 1.8+
- VirtualBox 4.3+
- Ansible 2.0+

Run `./script/setup` to install project dependencies and prepare the development environment.

At this point, if you only intend to run the 'Bike Network Analysis', skip directly to [Running the Analysis](#running-the-analysis)

Then, SSH into the VM and start the application containers:
```
> vagrant ssh
> ./scripts/server
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

Copy the 'neighborhood_boundary_02138.zip' file on fileshare and unzip to `./data/neighborhood_boundary.shp`

Run:
```
NB_INPUT_SRID=2249 NB_OUTPUT_SRID=2249 NB_BOUNDARY_BUFFER=11000 ./pfb-analysis/import.sh /vagrant/data/neighborhood_boundary.shp ma 25
NB_OUTPUT_SRID=2249 NB_BOUNDARY_BUFFER=11000 ./pfb-analysis/run_connectivity.sh
```

This will take up to 1hr, so just let it work. Consider piping script output to a file and running in
a screen/tmux session.

#### Re-running the analysis

If you want to run a different neighborhood, do the following:
- `vagrant ssh -c 'sudo -u postgres psql -c "DROP DATABASE pfb;"'`
- Place new datasets at the location described above in [Getting Started](#getting-started)
- `vagrant provision` to create a fresh pfb database
- Re-run `./pfb-analysis/import.sh`, passing arguments via ENV as described above
- Re-run `./pfb-analysis/run_connectivity.sh`, passing arguments via ENV as described above

If you want to run the same neighborhood without changing any of the import data, i.e. to test
changes to the analysis, simply re-run `./pfb-analysis/run_connectivity.sh`. The script is
idempotent.


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

# Additional arguments found in usage strings for scripts called by import.sh
NB_INPUT_SRID='<input srid>' NB_OUTPUT_SRID='<output srid>' ./pfb-analysis/import.sh \
    '<path to boundary file>' '<state abbrev>' '<state fips>'

```

This will create a VM, install the necessary dependencies, and load your neighborhood and
the associated data.

The database should now be ready for [Running the Analysis](#running-the-analysis)
