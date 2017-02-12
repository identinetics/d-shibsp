#!/bin/bash
set -e   # exit if a command fails

function main {
    # transition from root to daemon user is handled by shibd/httpd; must start as root
    if [ $(id -u) -ne 0 ]; then
        echo "must start shibd and httpd as root"
        exit 1
    fi
    cleanup_and_prep
    start_shibd
    start_httpd
}


function cleanup_and_prep {
    # config redirects log files from jetty standard location to linux default path
    mkdir -p /var/log/idp
    mkdir -p /var/log/jetty

    # correct ownership (docker run will reset the ownership of volumes to the uis passed with -u).
    # Only a problem with /etc/shibboleth, where mod_shib needs to have access with the httpd id
    chown -R $SHIBDUSER:shibd \
        /etc/shibboleth \
        /var/lock/subsys/ \
        /var/log/idp \
        /var/log/jetty

    # Make sure we're not confused by old, incompletely-shutdown shibd or httpd
    # context after restarting the container. httpd and shibd won't start correctly                                                                                                                                                        # if thinking it is already running.
    rm -rf /var/lock/subsys/shibd  \
           /var/run/shibboleth/shibd.*  \
           /run/httpd/*
}


function start_shibd {
    /usr/sbin/shibd -u shibd05 -g root -p /var/run/shibboleth/shib.pid > /var/log/shibboleth/shibd_startup.log 2>&1
}


function start_httpd {
    httpd -DFOREGROUND -d /etc/httpd/ -f conf/httpd.conf > /var/log/httpd/httpd_startup.log 2>&1
}


main
