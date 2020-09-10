#!/bin/bash

KUBECTL="kubectl --context=$HUB_DOMAIN_NAME"

$KUBECTL get -f profile.yaml 2>/dev/null \
  || $KUBECTL apply -f profile.yaml

$KUBECTL get namespace "$PROFILE" 2>/dev/null \
  || $KUBECTL apply --validate=false -f namespace.yaml
