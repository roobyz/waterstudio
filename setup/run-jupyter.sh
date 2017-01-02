#!/usr/bin/with-contenv sh
#
# This launches nginx without letting it daemonize/fork
#exec jupyter notebook --no-browser --NotebookApp.allow_origin='*' --notebook-dir='/home/rstudio'
exec jupyter notebook --NotebookApp.allow_origin='*' --notebook-dir='/home/rstudio'
