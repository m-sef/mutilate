#!/usr/bin/env bash

sudo helm repo add bitnami https://charts.bitnami.com/bitnami
sudo helm install my-cache bitnami/memcached \
  --set architecture="high-availability" \
  --set replicaCount=2 \
  --set fullnameOverride=memcached-service \
  -n memcached \
  --create-namespace

exit 0