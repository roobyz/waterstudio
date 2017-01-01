# Overview

This repository contains a Dockerfile for a Docker container running RStudio Server with H2O included. We start with the minimal Ubuntu image from Phusion and add the S6 process supervisor for a small Docker-friendly image. Also, to enhance performance we include OpenBlas as the default Linear Algebra library, which provides some of the fastest optimizations on x86 hardware, without the licensing restrictions and fees of the Intel MKL libraries.

# Getting Started

To get started right away, ensure you have Docker installed and start a container with docker run --rm -ti rocker/r-base (see here for the docker run command options). In this case we are starting the r-base container (the base package to build from) in an interactive mode, see below for details of the other containers currently available. To get started on the rstudio container or its derivative containers (eg. hadleyverse and ropensci) you need to open a port, see the instructions in the wiki. The wiki also contains further instructions and information on the project, including how to extend these images and contribute to development.


# Build the new docker image.
docker build -t roobyz/waterstudio .


## Once all good.
## Create a reusable container with default user and password: rstudio/rstudio
docker create --name rstudio.server roobyz/waterstudio

## Create a reusable container with custom user and password
docker create --name rstudio.server -e USER=<username> -e PASSWORD=<password> roobyz/waterstudio

docker create --name rstudio.server -e USER=roobyz -e PASSWORD=rstudio roobyz/waterstudio

mkdir ~/rstudio/code
docker create --name rstudio.server \
    -v ~/rstudio/code/:/home/rstudio/code:rw \
    -e USER=roobyz -e PASSWORD=rstudio \
    roobyz/waterstudio

# Reuse the same container
docker start rstudio.server

docker inspect --format '{{ .NetworkSettings.IPAddress }}' rstudio.server
docker exec -i -t rstudio.server /bin/bash

docker stop  rstudio.server
docker rm rstudio.server


## Debugging: ssh into the image
docker run --rm -it $(docker images -q roobyz/waterstudio) /sbin/my_init -- bash -l
docker run --rm -it $(docker images -q roobyz/waterstudio) /init -- bash -l
docker run --rm -it $(docker images -q roobyz/waterstudio) /bin/bash
docker rmi $(docker images -q roobyz/waterstudio)


https://h2o-release.s3.amazonaws.com/h2o/rel-lambert/5/docs-website/Ruser/top.html
http://www.skarnet.org/software/s6/index.html
https://hub.docker.com/r/rocker/rstudio/~/dockerfile/
https://github.com/phusion/baseimage-docker
http://pothibo.com/2015/7/how-to-debug-a-docker-container
https://docs.docker.com/v1.8/reference/commandline/build/
https://github.com/QuantumObject/docker-rstudio
https://github.com/xianyi/OpenBLAS
