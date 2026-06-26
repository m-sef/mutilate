#!/usr/bin/env bash
# Author(s): Author(s): m-sef (https://github.com/m-sef)

NAMESPACE=$1
POD=$2

sudo kubectl exec -n $NAMESPACE $POD -it -- /bin/sh

exit 0;