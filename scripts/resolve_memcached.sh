#!/usr/bin/env bash
# Author(s): m-sef (https://github.com/m-sef)

getent hosts memcached-service.memcached.svc.cluster.local | awk '{print $1}'

exit 0