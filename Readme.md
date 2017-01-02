# WateRStudio

## Overview

This repository contains a Dockerfile to build a [Docker] container for securely serving up [H2O] on [RStudio] or [Jupyter] using [Nginx] as an encrypted proxy server.

Container objective: facilitate learning and running data-science projects using:

* A pre-configued, secure, standardized, and self-contained environment.
* A big-data friendly setup through H2O using R, and/or Python.
* A platform (Jupyter) for conducting collaborative reproducible research.

## Getting Started

### Install Docker

Windows, Mac, or Linux users can find complete installation instructions on the [docker getting started] page. Although you don't need to be a *command-line* wizard, you should be familiar with how to open your favorite shell or terminal, and run a few basic commands.

### Install a WateRStudio Software Image

Once you have Docker installed,

1. Create a shared folder for storing code that you will create in your docker container to your local computer (i.e. `mkdir -p ~/rstudio/code`).
2. Open a command-line terminal.
3. Read these notes and modify the following command as necessary:

    a) If you'd like, change your container name (*waterstudio*) to one you prefer. This is especially useful if you wan't to test different container versions without losing your existing one.

    b) Map the shared folder into the container home folder that you created.

    c) Set your user name and password or remove the line for a default of: rstudio/rstudio.

    d) The port entries map the container ports to your localhost ports.

4. Run the following docker command (with modifications as desired):

``` docker
docker create --name waterstudio \
      -v ~/rstudio/code/:/home/rstudio/code:rw \
      -e USER=[username] -e PASSWORD=[password] \
      -p 80:80 -p 443:443 \
      roobyz/waterstudio
```

## Usage

Once your container is created, you can start and stop the container as follows:

> docker start *waterstudio*

> docker stop *waterstudio*

If you want to delete your container, first stop it and then run:

> docker rm *waterstudio*

## Accessing the Applications

Once you have started your container, you may log in to RStudio through this link:

> https://localhost/rstudio/

Once you have initialized your H2O library you can connect to H2O Flow with this link:

> https://localhost/flow/

## Advanced

If you need to update or change to your docker container, you may access the docker terminal as follows:

> docker exec -i -t waterstudio /bin/bash

## More Information

### Background

The container starts with a minimal [Ubuntu OS] image from [Phusion] with the [S6] process supervisor added for a small Docker-friendly image. To enhance R specific code performance, [OpenBlas] is included as the default Linear Algebra library, which provides some of the fastest noncommercial linear algebra optimizations.

### Additional Links

RStudio Server [Documentation]

Using [R On H2O]

[H2O Documentation]

Visit the [roobyz/waterstudio] GitHub page to help improve this container.

[docker]: https://www.docker.com/what-docker "Docker: Open Platform for Application Containers"
[docker getting started]: https://docs.docker.com/engine/getstarted/ "Docker: Getting Started"
[docker overview]: https://docs.docker.com/toolbox/overview/ "Docker Installation Overview"
[documentation]: https://support.rstudio.com/hc/en-us/categories/200035113-Documentation]
[h2o]: http://www.h2o.ai "H2O: Open-source distributed Machine Learning"
[h2o documentation]: http://docs.h2o.ai "H2O Documentation"
[h2o flow]: http://www.h2o.ai/product/flow/ "Flow open-source user-interface for H2O"
[intel mkl]: https://software.intel.com/en-us/intel-mkl "Intel Math Kernel Library"
[jupyter]: https://jupyter.org/ "Jupyter: Interactive Data Science Notebook"
[linux distribution]: https://docs.docker.com/engine/installation/linux/ "Docker: Linux Installation"
[nginx]: https://www.nginx.com/ "NGINX | High Performance Reverse Proxy Server"
[openblas]: https://github.com/xianyi/OpenBLAS "OpenBLAS: an optimized BLAS library"
[phusion]: https://github.com/phusion/baseimage-docker
[R On H2O]: https://h2o-release.s3.amazonaws.com/h2o/rel-lambert/5/docs-website/Ruser/top.html
[rstudio]: https://www.rstudio.com/home/ "RStudio for R"
[s6]: http://www.skarnet.org/software/s6/index.html "skarnet's small and secure supervision software suite"
[ubuntu os]: http://www.ubuntu.com/ "Linux-Based Operating System"
[roobyz/waterstudio]: https://github.com/roobyz/waterstudio "GitHub Repository"