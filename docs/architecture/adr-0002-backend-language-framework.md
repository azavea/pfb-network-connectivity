# 0002 - Backend Language / Framework

## Context

A backend web framework significantly eases the amount of boilerplate necessary for an application to handle web requests. Additionally, it provides scalable, out of the box, well-tested solutions for common features such as user management, authentication, database interaction, and a public API.

This project will mostly require only the common components described above, so a backend web framework that we are familiar with will speed development for the project. The only unknown is the integration of the asynchronous 'Bicycle Network Analysis' task mentioned in [ADR 0001](adr-0001-development-environment.md)

The team is most familiar with Python, Django and the Django Rest Framework. Due to project constraints and the desired functionality, no other backend frameworks were considered for this project.


## Decision

The team will use Django with the Django Rest Framework plugin, written in Python. The team's familiarity with this stack is too much of a positive to pass up. In addition, Django provides many third-party solutions for integrating the asynchronous 'Bicycle Network Analysis' task. This allows the team to be flexible when choosing a solution, without sacrificing development efficiency.

## Conesquences

We expect the consequences for this decision to be relatively minimal. The team has considerable experience with Python and Django, both of which provide a large amount of flexibility for future decisions and project scope changes.
