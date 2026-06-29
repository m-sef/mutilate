#!/usr/bin/env bash
# Author(s): Seth Moore (https://github.com/m-sef)
# Quickly run container and access it via shell. Container will be destroyed upon exiting.

sudo docker run --rm -it mutilate:latest bash

exit 0