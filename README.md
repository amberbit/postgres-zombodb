# Docker image for PostgreSQL 14 with ZomboDB extension built

This Dockerfile builds (in multistage build) [ZomboDB](https://github.com/zombodb/zombodb) extension and packages it into otherwise unchanged default postgres:14 official PostgreSQL docker image.

Published to Docker Hub:

https://hub.docker.com/repository/docker/amberbit/postgres-zombodb
