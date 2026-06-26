#!/usr/bin/env bash
# Author(s): m-sef (https://github.com/m-sef)

AGENT=$1

getent hosts mutilate-agent-$1.mutilate-agent-headless.mutilate.svc.cluster.local | awk '{print $1}'

exit 0