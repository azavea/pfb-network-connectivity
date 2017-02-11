# 0004 - Asynchronous Task Queue (AWS Batch)

Supersedes [ADR0003](adr-0003-asynchronous-task-queue.md)

## Context

In ADR0003, we described the 'Bicycle Network Analysis' task to be run via an asynchronous task queue. Since then, Amazon Web Services (AWS) released a new service simply named 'Batch'. This service provides a managed task queue, with Boto and HTTP API interfaces for creating queues and jobs, and triggering new jobs. Each job in AWS Batch is configured to run a Docker container provided to the job configuration. AWS Batch manages ordering and execution of tasks in the queue. In almost every way, AWS Batch is a superior choice to the strategy outlined in ADR 0003, for a few key reasons:

 - AWS Batch manages the queue and task autoscaling without any management from the parent application. The service can be trivially configured to scale up or down on a few different resource considerations. If there are no jobs in the queue, the pool of workers will automatically scale to zero, saving on hosting costs.
 - AWS Batch, in comparison with a manually managed stack of celery workers + broker + result backend, is easy to configure, as it only requires defining a "worker" stack via a JSON cofiguration.
 - Switching from a Celery and ECS task based solution will be easy, as AWS Batch workers are configured with Docker containers in the same way as ECS tasks would be
 - It will be easier to trigger jobs from Django using AWS Batch, since direct calls can be made via Boto, rather than having to write some management layer to trigger ECS tasks or work with the Celery API.


## Decision

The team will build the Bicycle Network Analysis task queue on AWS Batch. The reduction in manual task queue management and ease of configuration should vastly outweigh having to learn how to develop applications using an unfamiliar service. While relatively new, AWS Batch has support in both Boto and via HTTP API and manual setup of a Batch stack was relatively straightforward.

## Consequences

While researching AWS Batch, a few concerns were raised:
- Our analysis jobs require significant scratch disk space. Initially, we will be able to configure our Batch job stack with EC2 instances that have additional local storage space provisioned, such as the `c3.xlarge` EC2 type. If this is unsufficient for any reason, we will need to look at manually attaching EBS volumes to job stack instances when they launch.
- AWS Batch can configure pools of worker machines in either managed or unmanged mode. Unmanaged mode is required if custom EC2 instance AMIs are required, or more detailed configuration of the compute environment is required. Use of the unmanaged mode of the Batch compute environments would require additional tooling and configuration. As of now, we should be able to use the managed environment.
- AWS Batch is not yet supported in Terraform. We'll need to manually manage the Batch compute environment and job queues outside of Terraform, which is not ideal. We think this is worth the additional overhead based on the time/complexity savings that Batch provides.

Another major concern is that this is untested technology at Azavea, on a project with some difficult deadlines and requirements. Use of AWS Batch is currently deemed an acceptable risk, due to the ease of configuration, and the large time savings it will provide over configuring and maintaining the more managed solution previously outlined.
