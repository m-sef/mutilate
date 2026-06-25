#!/usr/bin/env bash
# Author(s): m-sef (https://github.com/m-sef)
# WARNING - Relies on deprecated tools!

sudo docker build -t webserver .
sudo docker save -o webserver.tar webserver:latest
sudo ctr -n=k8s.io images import webserver.tar
sudo ctr -n=k8s.io image list | grep webserver

exit 0