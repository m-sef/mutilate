#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

sudo helm repo add bitnami https://charts.bitnami.com/bitnami
sudo helm install my-cache bitnami/memcached \
  --set architecture="high-availability" \
  --set replicaCount=2 \
  --set fullnameOverride=memcached-service \
  -f "$SCRIPT_DIR/bitnami-memcached-values.yaml" \
  -n memcached \
  --create-namespace

exit 0