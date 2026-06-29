#!/usr/bin/env bash

helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-cache bitnami/memcached \
  --set architecture="high-availability" \
  --set autoscaling.replicas=2 \
  --set fullnameOverride=memcached-service \
  -n memcached \
  --create-namespace

exit 0