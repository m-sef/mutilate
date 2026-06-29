#!/usr/bin/env bash
# Author(s): Seth Moore (https://github.com/m-sef)

NAMESPACE=$1
POD=$2

sudo kubectl exec -n $NAMESPACE $POD -it -- /bin/bash

exit 0;