# 0003 - Asynchronous Task Queue

## Context

The key component of this project is a 'Bicycle Network Analysis' task which is run on an arbitrary, user-provided neighborhood boundary. This task performs the following actions:
- Import neighborhood boundary into a PostgreSQL database
- Download OSM extract for the provided neighborhood boundary + a buffer and import to PostgreSQL
- Download related census block and job data for the boundary and import to PostgreSQL
- Generate a network graph from the imported data
- Run a series of client-provided analyses on the graph and imported data
- Export relevant data to an external file store for archival
- Generate a tile set of the network graph for display on a web map

The application will be configured with multiple organizations, and each organization can only run one analysis job at a time. A new analysis job triggered by a user of the organization will supersede any existing older analysis, which can be thrown away.

Since the analysis workflow is already a self-contained process, there are a few ways to trigger this job, and a few options for an asynchronous task queue. One option is to use Celery, a tool we are familiar with, to provide a known interface to trigger these analysis jobs. Another is to configure the analysis as an AWS ECS task, and have the application use the ECS API or Boto to start a new analysis.

Celery has multiple options for brokers:

| Broker | Advantages | Disadvantages |
| ------ | ---------- | ------------- |
| SQS | Cheap, easy to set up, now stable, provides configuration options to isolate environments | No result backend, [potential issues with result timeouts](http://docs.celeryproject.org/en/latest/getting-started/brokers/sqs.html#caveats) |
| Redis | Trivial to configure, can additionally be used as a results backend without further architecting | Key eviction issues, additional cost to run dedicated instance |

Running the analysis via AWS Lambda was briefly considered, but the project dependencies and resources required are not conducive to that environment.

## Decision
The team will use Celery + SQS broker to manage the asynchronous analysis jobs. While Celery is not strictly necssary, it provides a potentially useful abstraction layer for triggering tasks, managing jobs and reporting errors. Celery also provides out of the box support for Django and allows us to write any peripheral task logic in Python. The SQS broker was chosen to keep the managed application architecture simple and reduce ongoing application stack costs. The team is familiar with an older version of the SQS broker used for the Cicero District Match project.

## Consequences
It may be determined that the overhead of celery is unnecessary, in which case it could be removed and ECS tasks could be directly triggered from Django. We may also determine that our choice of Celery broker is inadequate for the project, in which case this decision would need to be revisited.

The exact method of triggering the analysis tasks is still unknown. It is likely that analysis jobs will be configured as ECS tasks and triggered from Celery via Boto. Otherwise a library such as [docker-py](https://docker-py.readthedocs.io/en/latest/api/#create_container) could directly start a container from Celery. Another unknown is that we're not quite sure how to autoscale task capacity as analysis jobs are triggered. This will require further investigation as the project matures.
