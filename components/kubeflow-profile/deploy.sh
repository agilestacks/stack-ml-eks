#!/bin/bash

KUBECTL="kubectl --context=$HUB_DOMAIN_NAME"

$KUBECTL get -f profile.yaml \
  || $KUBECTL apply -f profile.yaml

$KUBECTL get namespace "$PROFILE" \
  || $KUBECTL apply -f namespace.yaml
