#!/usr/bin/with-contenv sh
#
# This launches nginx without letting it daemonize/fork
exec /usr/sbin/nginx -g 'daemon off;'
