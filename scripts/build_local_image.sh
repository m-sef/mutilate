#!/usr/bin/env bash
# Author(s): m-sef (https://github.com/m-sef)
# WARNING - Relies on deprecated tools!

sudo docker build -t mutilate .
sudo docker save -o mutilate.tar mutilate:latest
sudo ctr -n=k8s.io images import mutilate.tar
sudo ctr -n=k8s.io image list | grep mutilate

exit 0