The People For Bikes Bicycle Network Analysis app (the project we call “PFB” and they call “the BNA”) is a web platform that analyzes low-stress bicycle connectivity of communities. Using data from OpenStreetMap and the US Census, it rates how easy or difficult it is to get around and carry out day-to-day activities by bike, and presents numerical scores and map overlays capturing the analysis results.

This document is a high-level overview of the components of the app, with some context about how it’s implemented and deployed and, in some cases, how it came to be the way it is. The main purpose of the document is to help maintainers with limited context on the project get oriented and avoid getting tripped up by unknown unknowns.

## Deployment and development tooling

Deployment is to AWS via Terraform, using a fairly standard Azavea-style infra script with the tfvars and tfstate files stored on S3. The services run on ECS, except that the database uses RDS and the analysis uses Batch. The staging site is deployed via Github Actions; the production site is deployed by hand, per the instructions in [deployment/README.md](https://github.com/azavea/pfb-network-connectivity/blob/develop/deployment/README.md), but per [issue #965](https://github.com/azavea/pfb-network-connectivity/issues/965) will be moved to Github Actions soon.

Local development uses Docker Compose. The services are set up to closely replicate the deployed environment, including using `links:` and `ports:` config to make the local docker network replicate the internal network in the VPC. The database in the local environment is a PostGIS container. The local environment does not include an equivalent to AWS Batch, so the analysis has to be run by hand, as described further below.

## Analysis

The conceptual core of the project is the analysis. It evaluates the low-stress bicycle connectivity of a place (most of the analyzed places are cities, but they could be neighborhoods within a large city or a group of small towns, so the user-facing term is “Place” and the internal term, for reasons of history and to make it easier to distinguish it as a technical term within the context of the code, is “Neighborhood”), assigning scores to the bike-friendliness of the roads and paths then analyzing how easy or difficult it is to move around the community using low-stress bicycle routes. The results are displayed—using tables for the scores and maps for the stress ratings of the roads and accessibility ratings of the areas within the neighborhood—in the user-facing web app.

People For Bikes manages the neighborhoods and runs the analysis jobs, using the admin side of the web app. They typically re-run the analysis for every neighborhood annually to keep the scores in sync with changes in the OpenStreetMap data.

The analysis runs in a self-contained, Dockerized environment that:

- Takes the S3 location of a neighborhood boundary shapefile as a parameter (plus some other parameters about the location of the neighborhood and where to store results)
- Spins up a Postgres database, with the PostGIS and pgrouting extensions installed
- Downloads an OpenStreetMap extract for the state where the neighborhood is located
- Imports features from the OSM extract, but clipped to the neighborhood boundary plus a buffer.
  - The resulting table of road and path segments is called “neighborhood_ways”.
  - It also imports some types of services and amenities, e.g. schools, grocery stores, medical offices, etc., which are used in the accessibility score calculations and exported for display on the map.
- Downloads census block and jobs data from the US census
- Imports the census blocks that intersect the (buffered) neighborhood boundary, and merges the jobs data into the imported census blocks (the table is “neighborhood_census_blocks”)
- Assigns a stress score to every road or path segment, based on the properties (e.g. speed limit, bike infrastructure) in the OSM data
- Calculates, for each census block, whether it can be reached from every other census block via low-stress bicycle routes, and assigns an accessibility score to the block
- Calculates the average accessibility of jobs and services within the neighborhood, based on the jobs data attached to the census blocks and the locations of services/amenities imported from OSM.
  - Scores are assigned for the accessibility of specific services (e.g. hospitals, parks), for groups of related services (e.g. “Opportunity”, which includes jobs and education, “Recreation” which includes parks and trails), and for the neighborhood as a whole.
- Exports the results, including:
  - a table of the scores assigned to the neighborhood as a whole and to each of the services and groups of services
  - shapefiles of the `neighborhood_ways` and `neighborhood_census_blocks` tables with all their metadata and scores included.

The connections between the analysis and the rest of the app are:

- At the beginning, it receives input parameters
- While it’s running, it sends status updates to the back end. It does so not via the API, but by running a Django management command that uses the same settings as the back end app to write the updates directly to the database.
- When it’s done, it
  - Uploads the files it produced to S3
  - Uses a few more management commands to load the calculated data—including the ways and census blocks geometries—into the back end database

The analysis was based on a proof-of-concept implementation by a different contractor (Spencer Gardner at Toole Design Group), which Azavea was tasked with packaging and deploying. The result is sort of an odd bird—a multi-process Docker container running Bash and PostgreSQL scripts for the most part, but with a few Python scripts as part of the analysis and a full Django environment loaded into the container but not running, to enable the management command interface.

### Deployment and local development

The analysis is deployed to AWS Batch. Because it was created before Fargate, and because the analysis needs a lot of scratch disk space, the compute environment is manually configured to use an instance class with a large amount of high-speed scratch storage space available (and also quite a bit of CPU and memory). Because the instances are expensive and analysis jobs are mostly run all at once during an annual update and seldom in between, the auto-scaling group size for the Batch environment instances is set to zero in the tfvars file. When some instances are needed to run analysis jobs, People For Bikes increases the instance count manually in the AWS console.

For creating and updating neighborhoods and analysis jobs locally, the admin views in the front end mostly work the same way they do on the deployed site—you can use them to add and edit neighborhoods and trigger individual or batch analysis jobs (see more on that below). The big exception is that rather than configure actual Batch environments for local development, we went with a strategy of creating a driver script to run the analysis container locally and provide it with all the environment variables and parameters it needs. Inside the container, a local analysis works pretty much the same as a remote one, and it has access to the local back end to write its status updates and results in the same way that the remote container does. Bt without the Batch environment and the queue setup that comes with it, the process of kicking off an analysis job locally is much more manual.

In the deployed environment, using the front end to create an analysis job involves sending a POST request to the `analysis_jobs` API endpoint, which composes the parameters necessary to submit a Batch job and submits it to the Batch queue. What we have instead, in the local environment, is that the Django view composes a command line for running the analysis locally, including all the parameters and environment variables needed, and prints it to the logs. So we have to fill the role of the Batch queue/runner by finding that command in the log output of the running Django container, copying it into a terminal, and running it.

If you want to hand-craft a local analysis invocation, or to see some explanation of what the parameters included in the composed command are, there’s documentation in the [README.LOCAL-ANALYSIS.md](https://github.com/azavea/pfb-network-connectivity/blob/develop/README.LOCAL-ANALYSIS.md) file.

To debug a local analysis, you can create breakpoints in the [Bash scripts](https://github.com/azavea/pfb-network-connectivity/tree/develop/src/analysis) by adding a line that calls `bash`. That will launch an interactive shell with all the environment variables that were exported in the parent script, where you should be able to test commands and get results that match what you would get in the running analysis (note: exiting out of that shell will return you to the running analysis). You can also use `docker exec -ti <container> bash` to get an interactive shell in the running container without interrupting the analysis.

## Front end

The front end is written in AngularJS and built with Grunt and Bower. These are old tools, but there’s nothing very fancy or unusual in the build, so it has been working reliably with occasional small tweaks for years.

There are two groups of pages/views in front end:

- The public site ([https://bna.peopleforbikes.org/#/](https://bna.peopleforbikes.org/#/), [https://bna.peopleforbikes.org/#/places////](https://bna.peopleforbikes.org/#/places////), etc) where the analysis results are presented, with charts and an interactive map.
- The management site ([https://bna.peopleforbikes.org/#/admin/analysis-jobs/](https://bna.peopleforbikes.org/#/admin/analysis-jobs/), [https://bna.peopleforbikes.org/#/admin/neighborhoods/](https://bna.peopleforbikes.org/#/admin/neighborhoods/), etc) where People For Bikes adds neighborhoods and triggers analysis runs.

The management site requires authentication, which uses a Django user management setup, that’s fairly standard but includes some permission levels and organization management features. These are essentially not used—the original vision included enabling planners or advocates outside of People For Bikes to create neighborhoods and run analysis jobs, but that part of the plan never materialized.

### Triggering analysis jobs

New jobs are created via one of the buttons at the top of the [Analyis Jobs admin view](https://bna.peopleforbikes.org/#/admin/analysis-jobs/). There are three options:

- Run Analysis: This creates a single analysis job for one neighborhood—the form you get when you push the button has a droplist of all the neighborhoods in the database. The form also includes optional fields for overriding some defaults or providing customized input files to use instead of the standard ones that get downloaded by the analysis.
- Run Batch: Because PFB typically runs updates all at once, and creating each neighborhood and submitting an analysis for it would get very cumbersome over hundreds of neighborhoods, we added an option to submit a shapefile containing many neighborhoods. When a batch job is submitted, the back end loads the file and treats each geometry that it defines as a neighborhood, with its name and other metadata stored in the properties table. For each neighborhood in the file, it adds a neighborhood instance to the database if it doesn’t already exist, or updates it if it does, then submits an analysis job for that neighborhood to the Batch queue.
- Import Analysis: Running a normal analysis for non-US cities doesn’t work because they don’t have census blocks or census-provided jobs data. However, it’s often possible to find equivalent data sources and run the analysis locally on a modified branch, and People For Bikes has been producing non-US analysis runs that way for some time. The “Import” functionality makes it possible to load and display the results of those customized analysis runs alongside the US ones produced by the normal process.

**Deployment**
Unlike the recent norm of deploying front ends by putting the static bundle on S3 and serving it via CloudFront, for this project the built asset bundle is copied into an Nginx container and served from an ECS service.

## Back end

The back end consists of a Django Rest Framework API and a PostgreSQL+PostGIS database.
The main models are Neighborhood and AnalysisJob, and most of the other models are related to those two—either storing many-to-one relations or modeling parts of the workflow (e.g. AnalysisJobStatusUpdate). One exception is the Crash model, which stores crash data (from a static data source loaded via management command) for display on the map.

One aspect of the models that’s worth noting is that the public site is organized around neighborhoods but most of the information that actually shows up there is on the AnalysisJob model, and while the Neighborhood instances are kept permanently and updated as needed (e.g. with changes to the parameters or border geometry), an AnalysisJob instance represents a single analysis run. So the scores, map layers, and downloadable results files on the neighborhood view come from the most recently-completed analysis run, and when a new run is completed, the map tile URLs and download links will change to include the new AnalysisJob instance’s UUID. Because almost every API call for neighborhood information requires at least some fields from the latest analysis, we added a denormalized field to the Neighborhood model, called `last_job`. It’s a nullable foreign key that points to the most recent successful analysis job for the neighborhood. The value is kept in sync by the `AnalysisJob.update_status()` method.

### Django Q

In addition to the Django service, we also run a [Django Q](https://django-q.readthedocs.io/en/latest/) service to handle some of the processing tasks that are triggered by API interactions but won’t fit in a request/response cycle. Namely:

- Processing batch files, by opening them up, saving each geometry as a neighborhood, and submitting a Batch job for each.
- Loading analysis imports, which includes opening the `neighborhood_ways` and `neighborhood_census_blocks` shapefiles and writing their contents to the database.

## Tiler

This project contains the sole production deployment of [Tilegarden](https://github.com/azavea/tilegarden), the dynamic tiler that uses Mapnik on Lambda to create raster tiles from PostGIS geometries. It doesn’t actually use Tilegarden as a package or Terraform module, though, because Tilegarden hadn’t been developed to the point where it could just be dropped in, and we didn’t want to be stuck developing and debugging the PFB implementation across two repositories, so we copied it in and did what we needed to do in the PFB repo.

The tiling needs of the project are to be able to show the road network and census blocks scores on the map, styled according to their calculated stress and accessibility scores (there’s also a layer showing bike infrastructure, also based on the road network geometries). The original strategy was to pre-render the entire tile pyramid for both output files of every analysis run. This was time consuming and produced a _lot_ of files on S3, the vast majority of which would likely never be needed. What Tilegarden does instead is it renders tiles on demand, then both returns them to the user and stores them in S3, so subsequent requests for the same tile will be served from the S3 cache. That means each tile that’s needed for an actual map view requested by a user gets generated only once, and all the tiles that no one ever tries to look at don’t get generated at all.

Some other things to know about the tiler:

- The AWS Lambda “cold start” problem applies, so there’s an EventBridge event that triggers tile generation every 15 minutes to keep one Lambda worker warmed up and ready. This doesn’t prevent cold-start effects completely, because most map loads will result in requests to more than one parallel Lambda worker, but between the one warm worker and the cache, it’s enough to prevent a map view from just showing nothing for an extended period.
- The calculated geometries are associated with analysis jobs, i.e. the scores are for a particular run, and a new job will produce new outputs. Since the site only shows the latest analysis job for a given neighborhood, once a new job has been run the old cached tiles become obsolete. We never defined a lifecycle rule to clean them up, but in principle you would not expect tiles that are older than ~15 months to ever be needed.

The big thing to know about the tiler is that it has been living on inertia for a long time. The tiler code itself is fairly simple, but the deployment code (it uses [Claudia.js](https://github.com/claudiajs/claudia) for the Lambda and API Gateway components and Terraform for the S3/CloudFront parts) is a bit more complex, and it has been unmaintained in production since [Issue #843](https://github.com/azavea/pfb-network-connectivity/issues/843). It just keeps working, though—the runtime it uses is EOL and couldn’t be redeployed without upgrading it, but the deployed Lambda function keeps plugging away. It also works in local development, so the obstacles to updating the deployed version, if necessary, might not be too high.
