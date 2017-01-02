## roobyz/rstudio-server
##
## RStudio Server on minimal Ubuntu 16.04.
## Default username=rstudio and password=rstudio
## Thanks to "phusion/baseimage", "rocker/rstudio" and "mccahill/r-studio" for their
## excellent work, which was the basis for this docker image.
##
## VERSION 0.4.5

## To make your builds reproducible, make sure you lock down to a specific version, not to `latest`! 
## See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for a list of version numbers.
## FROM phusion/baseimage:<VERSION>
FROM phusion/baseimage:0.9.19

MAINTAINER Roberto Rivera "Roberto.Rivera.Z@gmail.com"

## Add RStudio PATH and set other environment variables
ENV PATH /usr/lib/rstudio-server/bin/:$PATH
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV R_BASE_VERSION 3.3.1

################################################################################
## Basic Foundation
################################################################################
## Set a default user. Available via runtime flag `--user rstudio` 
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (for rstudio or linked volumes to work properly). 
## Add the Ubuntu R-studio repository, and Ubuntu R-studio key
## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
## s6-overlay automates integration of s6 (asynchronous rewrite of daemontools for embedded systems) into Docker images.
## Required by the subsequent userconf script.
RUN useradd rstudio && \
    mkdir /home/rstudio && \
    chown rstudio:rstudio /home/rstudio && \
    addgroup rstudio staff && \
    echo '"\e[5~": history-search-backward' >> /etc/inputrc && \
    echo '"\e[6~": history-search-backward' >> /etc/inputrc && \
    echo "rstudio:rstudio" | chpasswd && \ 
    sh -c "echo 'deb http://cran.rstudio.com/bin/linux/ubuntu xenial/' >> /etc/apt/sources.list" && \
    gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 && \
    gpg -a --export E084DAB9 | apt-key add - && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.utf8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8 && \
    apt-get update && apt-get upgrade -y -q && apt-get dist-upgrade -y && apt-get install -y wget apt-utils && \
    apt-get clean && apt-get autoremove && \
    wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && mkdir /etc/services.d/jupyter/ && rm -rf /etc/service/

################################################################################
## Basic Software
################################################################################
RUN apt-get install -y -q --no-install-recommends \
        ed \
        less \
        locales \
        vim-tiny \
        ca-certificates \
        file \
        git \
        gettext-base \
        lsof \
        libxml2-dev \
        openjdk-8-jre \
        build-essential \
        libgsl0-dev \
        libjpeg-dev \
        libncurses5-dev \
        libpng12-dev \
        libsqlite3-dev \
        libopenmpi-dev \
        libnetcdf-dev \
        markdown \
        texlive-latex-base \
        texlive-latex-recommended \
        texlive-latex-extra \
        texlive-fonts-extra \
        texlive-generic-recommended \
        texlive-science \
        texlive-font-utils \
        texlive-lang-spanish \
        latex-beamer \
        xsltproc \
        zlib1g-dev \
        libapparmor1 \
        libedit2 \
        libcurl4-openssl-dev \
        libssl-dev \
        psmisc \
        unzip \
        bzip2 \
        sudo \
        nginx && \
    apt-get clean && apt-get autoremove

################################################################################
## R Software
################################################################################
RUN apt-get install -y -q --no-install-recommends \
        libopenblas-base \
        littler \
        r-cran-littler \
        r-base=${R_BASE_VERSION}* \
        r-base-dev=${R_BASE_VERSION}* \
        r-recommended=${R_BASE_VERSION}* && \
    apt-get clean && apt-get autoremove && \
    echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site && \
    echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r && \
    ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r && \
    ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r && \
    ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r && \
    ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r && \
    install.r docopt && \
    VER=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) && \
    wget -q http://download2.rstudio.org/rstudio-server-${VER}-amd64.deb && \
    dpkg -i rstudio-server-${VER}-amd64.deb && \
    rm rstudio-server-*-amd64.deb && \
    ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin && \
    ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc-citeproc /usr/local/bin && \
    wget https://github.com/jgm/pandoc-templates/archive/1.15.0.6.tar.gz && \
    mkdir -p /opt/pandoc/templates && tar zxf 1.15.0.6.tar.gz && \
    cp -r pandoc-templates*/* /opt/pandoc/templates && rm -rf pandoc-templates* core 1.15.0.6.tar.gz && \
    mkdir /root/.pandoc && ln -s /opt/pandoc/templates /root/.pandoc/templates

## Ensure that if both httr and httpuv are installed downstream, oauth 2.0 flows still work correctly.
RUN echo '\n\
\n# Configure httr to perform out-of-band authentication if HTTR_LOCALHOST \
\n# is not set since a redirect to localhost may not work depending upon \
\n# where this Docker container is running. \
\nif(is.na(Sys.getenv("HTTR_LOCALHOST", unset=NA))) { \
\n  options(httr_oob_default = TRUE) \
\n}' >> /etc/R/Rprofile.site && echo "PATH=$PATH" >> /etc/R/Renviron.site

################################################################################
## Python and Jupyter Software
################################################################################
RUN apt-get install -y -q --no-install-recommends \
        fonts-dejavu \
        gdal-bin \
        gfortran \
        libedit2 \
        libedit-dev \
        libgdal-dev \
        libhdf5-dev \
        libsm6 \
        libspatialindex-dev \
        llvm-3.7 \
        llvm-3.7-dev \
        python3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        zlib1g \
        zlib1g-dev && \
    apt-get clean && apt-get autoremove
    
RUN pip3 install --upgrade pip virtualenv && pip3 install numpy && \
    LLVM_CONFIG=/usr/bin/llvm-config-3.7 pip3 install llvmlite numba && export HDF5_DIR=/opt/local pip3 install tables && \
    pip3 install ipyparallel ipywidgets scipy matplotlib numexpr ipython jupyter pandas statsmodels scikit-learn scikit-image \
                 sympy pyzmq nose notebook cython patsy cloudpickle dill enum34 ggplot bokeh sqlalchemy h5py readline seaborn \
                 service_identity pydot-ng pymc nltk plotly feedparser gensim pymongo scrapy xgboost dateutils pyproj filterpy \
                 bash_kernel fysom hmmlearn JPype1 keras konlpy nlpy pudb rpy2 pydot descartes beautifulsoup4 boto bottleneck \
                 sqlalchemy rope cytoolz datashape jdcal lxml openpyxl fiona shapely grip requests tabulate wheel future six \
                 http://h2o-release.s3.amazonaws.com/h2o/rel-turing/3/Python/h2o-3.10.0.3-py2.py3-none-any.whl && \
    apt-get -f install && apt-get clean && apt-get autoremove

################################################################################
## R Packages: default, H2O, Jupyter
################################################################################
## Add script to install/update R packages.
COPY ./code/R-packages-script.R /home/rstudio
COPY ./code/h2o-update-script.R /home/rstudio

## Install the libraries
RUN R CMD BATCH /home/rstudio/R-packages-script.R && \
    R CMD BATCH /home/rstudio/h2o-update-script.R && \
    rm h2o-update-script.Rout R-packages-script.Rout

################################################################################
## Nginx Setup
################################################################################
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    ln -sf /etc/nginx/sites-available/waterstudio /etc/nginx/sites-enabled/default && \
    openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/waterstudio.key -out /etc/nginx/waterstudio.crt \
        -subj "/OU=Open Source/CN=home.lab"

## Add nginx configuration for secure proxy services and user configuration script. 
COPY ./setup/userconf.sh /etc/cont-init.d/conf 
COPY ./setup/reverse-proxy.conf /etc/nginx/sites-available/waterstudio
COPY ./setup/ssl_options.conf /etc/nginx/ssl_options.conf

## Add s6 daemon scripts
COPY ./setup/run-rserver.sh     /etc/services.d/rstudio/run 
COPY ./setup/run-nginx-proxy.sh /etc/services.d/nginx/run 
COPY ./setup/run-jupyter.sh     /etc/services.d/jupyter/run 
#COPY ./setup/finish.sh          /etc/services.d/rstudio/finish 
#COPY ./setup/finish.sh          /etc/services.d/nginx/finish 

## For network access to the container, open ports through the container firewall
## Default ports: RStudio server at 8787 and H2O server at 54321 
EXPOSE 80/tcp 443/tcp

## Expose a default volume for Kitematic
VOLUME /home/rstudio

## Use the s6 init system.
CMD ["/init"]
