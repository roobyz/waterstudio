## roobyz/rstudio-server
##
## RStudio Server on minimal Ubuntu 16.04. (docker run -d -p 8787:8787 roobyz/rstudio-server)
## Default username=rstudio and password=rstudio
## Thanks to "phusion/baseimage", "rocker/rstudio" and "mccahill/r-studio" for their
## excellent work, which was the basis for this docker image.
##
## VERSION 0.1.0

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

## Set a default user. Available via runtime flag `--user rstudio` 
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (for rstudio or linked volumes to work properly). 
## Add the Ubuntu R-studio repository, and Ubuntu R-studio key
## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
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
    /usr/sbin/update-locale LANG=en_US.UTF-8
 
## Download and install R, littler, and other dependencies
## Create a link for littler in /usr/local/bin
## Also set a default CRAN repo, and make sure littler knows about it too
## And we want OpenBLAS for faster linear algebra as described here: 
##   http://brettklamer.com/diversions/statistical/faster-blas-in-r/
## 
## Download and install RStudio server & dependencies
## Attempts to get detect latest version, otherwise falls back to version given in $VER
## Symlink pandoc, pandoc-citeproc so they are available system-wide
RUN apt-get update && \ 
    apt-get install -y --no-install-recommends \
        ed \
        less \
        locales \
        vim-tiny \
        wget \
        ca-certificates \
        file \
        git \
        lsof \
        libxml2-dev \
        openjdk-8-jre \
        libapparmor1 \
        libedit2 \
        libcurl4-openssl-dev \
        libssl-dev \
        psmisc \
        python-setuptools \
        sudo \
        libopenblas-base \
        littler \
        r-cran-littler \
        r-base=${R_BASE_VERSION}* \
        r-base-dev=${R_BASE_VERSION}* \
        r-recommended=${R_BASE_VERSION}* && \
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
    mkdir /root/.pandoc && ln -s /opt/pandoc/templates /root/.pandoc/templates && \
    apt-get -f install

## Ensure that if both httr and httpuv are installed downstream, oauth 2.0 flows still work correctly.
RUN echo '\n\
\n# Configure httr to perform out-of-band authentication if HTTR_LOCALHOST \
\n# is not set since a redirect to localhost may not work depending upon \
\n# where this Docker container is running. \
\nif(is.na(Sys.getenv("HTTR_LOCALHOST", unset=NA))) { \
\n  options(httr_oob_default = TRUE) \
\n}' >> /etc/R/Rprofile.site

## Add script to install/update H2O library for R.
ADD h2o-update-script.R /home/rstudio

## s6-overlay automates integration of s6 (asynchronous rewrite of daemontools for embedded systems) into Docker images.
## Required by the subsequent userconf script.
## Ensure that RStudio path is in the environment file and clean up when done.
RUN wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
    echo "PATH=$PATH" >> /etc/R/Renviron.site && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir /etc/service/rstudio-server && \
    R CMD BATCH /home/rstudio/h2o-update-script.R && \
    rm h2o-update-script.Rout

## Add user configuration script.
ADD userconf.sh /etc/cont-init.d/conf 

## Add s6 daemon script
ADD rstudio-server.sh /etc/services.d/rstudio/run 

## For network access to the container, open ports through the container firewall
## Default ports: RStudio server at 8787 and H2O server at 54321 
EXPOSE 8787/tcp 54321/tcp
#EXPOSE 8384/tcp 22000/tcp 21027/udp

## Expose a default volume for Kitematic
VOLUME /home/rstudio

## Use the s6 init system.
CMD ["/init"]
