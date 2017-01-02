#!/bin/sh
#
# This launches the R-Studio server without letting it daemonize/fork
exec /usr/lib/rstudio-server/bin/rserver --server-daemonize=0
