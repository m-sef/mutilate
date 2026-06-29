#!/usr/bin/env bash
# Author(s): Seth Moore (https://github.com/m-sef)
# WARNING - Relies on deprecated tools! Workaround for making Docker image available to Kubernetes

sudo docker build -t mutilate .
sudo docker save -o mutilate.tar mutilate:latest
sudo ctr -n=k8s.io images import mutilate.tar
sudo ctr -n=k8s.io image list | grep mutilate

exit 0