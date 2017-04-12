# 0001 - Development Environment

## Context

This application will require a fairly standard application stack - web server, database store and an asynchronous task queue. In the past, the team has used either Vagrant + Ansible or Docker + Docker Compose to build these application stacks.

In general, Docker containers improve the CI build and deployment workflows, at the expense of a slightly more complicated development environment, especially for users not using Linux. In the past, the team has wrapped the Docker environment within a barebones Ubuntu VM using Vagrant to streamline the development workflow across different OSes. Recently however, Docker released a new tool, Docker for Mac, which attempts to streamline native use of containers on macOS. This tool may eliminate the need for the wrapper VM, but has some potential pitfalls.

Previous projects defaulted to an Ubuntu VM, with the containers using the simplest debian-based OS. Azavea maintains a series of Docker containers that provide the building blocks for the application stack we will be building.

This project contains a 'Bicycle Network Analysis' task which is runs on a self-contained PostgreSQL instance. Running this via Vagrant+Ansible or a Docker container should be relatively straightforward either way, since the task has known software dependencies and does not have any external dependencies. When this project begain, this task was configured via Vagrant+Ansible. Some additional work would be necessary to convert this task to a Docker container.

## Decision
In order to take advantage of the better deployment and provisioning workflows provided by AWS ECS when using containers, we decided to construct the development environment using a Docker Compose environment wrapped within an Ubuntu VM. While Docker for Mac looks compelling, it has a few downsides:
- We cannot control the version of Docker installed, which could be problematic as the project ages
- There are potential incompatibilies for users with the older Docker Toolbox installed
- It may be difficult to cull outdated container images across projects
- It may be difficult to isolate various project instances and their dependencies

Using the wrapper VM avoids these issues and provides us with a relatively 'known good' experience for a project with somewhat limited budget constraints.

## Consequences
Constructing development environments as described above should be relatively straightforward. There are other projects at Azavea using this format and there are a few [good examples](https://github.com/azavea/pwd-stormdrain-marking) to bootstrap from.

Converting the 'Bicycle Analysis Task' to a Docker container may present a few difficulties, as some of the Ansible setup configures the PostgreSQL instance after it boots. Since the last step of a Dockerfile would only start the PostgreSQL instance, it may be necessary to move some of this post-start configuration to the scripts that run the analysis task.
