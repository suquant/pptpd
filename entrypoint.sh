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

echo "
name pptpd
debug

refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128

proxyarp
nodefaultroute
lock
nobsdcomp
novj
novjccomp
nologfd
ms-dns 8.8.8.8
ms-dns 8.8.4.4
plugin radius.so
plugin radattr.so" > /etc/ppp/options


echo "$RADIUS_SERVER    $RADIUS_SECRET" >> etc/radiusclient/servers
sed -i -r "s/authserver \tlocalhost/authserver \t$RADIUS_SERVER/g" /etc/radiusclient/radiusclient.conf
sed -i -r "s/acctserver \tlocalhost/acctserver \t$RADIUS_SERVER/g" /etc/radiusclient/radiusclient.conf

echo "$DNS_SERVER" > /etc/resolv.conf

#iptables -A INPUT -p tcp --dport 1723 -j ACCEPT
#iptables -A INPUT -p 47 -j ACCEPT

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

syslogd -n -O /dev/stdout &

exec /usr/sbin/pptpd -f $@
