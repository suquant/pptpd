#!/bin/sh
#
# This script is designed to be run inside the container
#

# fail hard and fast even on pipelines
set -eo pipefail

# set debug based on envvar
[[ $DEBUG ]] && set -x

if [ -h /etc/raddb/mods-available/sql ]; then
  echo "!!! sql module not supported, please install it !!!"
  exit 0
fi

if [ ! -d /var/lib/pptpd ]; then
    mkdir -p /var/lib/pptpd
fi

echo "name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128

plugin radius.so
plugin radattr.so

ms-dns 8.8.8.8
ms-dns 8.8.4.4

proxyarp
debug" > /etc/ppp/options

echo "$RADIUS_SERVER    $RADIUS_SECRET" >> etc/radiusclient/servers

syslogd -n -O /dev/stdout

exec /usr/sbin/pppd --fg $@
