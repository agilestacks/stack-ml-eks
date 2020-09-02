#!/bin/bash -e

KUBECTL="kubectl --context=$HUB_DOMAIN_NAME"
KUBECTL_DELETE="$KUBECTL -n "$PROFILE" delete --all"
UNWANTED="namespace events endpoints bindings "
UNWANTED="localsubjectaccessreviews.authorization.k8s.io $UNWANTED"
# profiles is a cluster level resource
# UNWANTED="profiles.kubeflow.org $UNWANTED"

echo "Cleaning up dangling resources in $PROFILE namespace..."

if test -z "$(which parallel)"; then
  echo "Warning: parallel cannot be found"
  echo "parallel will make clean up faster"
else 
  KUBECTL_DELETE="parallel -j 15 $KUBECTL_DELETE"
fi

for R in $($KUBECTL api-resources --namespaced=true -o name); do
  if grep -q "$R" <<< "$UNWANTED"; then
    continue
  fi
  echo "Deleting $R..."
  $KUBECTL_DELETE "$R"
done

if $KUBECTL get "profiles.kubeflow.org" "$PROFILE" > /dev/null 2>&1; then
  $KUBECTL get "profiles.kubeflow.org" "$PROFILE" -o json \
  | jq '. | del(.metadata.finalizers) | del(.spec.finalizers)' \
  | $KUBECTL replace -f -
  $KUBECTL delete -f "profile.yaml"
fi

$KUBECTL get namespace "$PROFILE" > /dev/null 2>&1 && exit
$KUBECTL get namespace "$PROFILE" -o json \
  | jq '. | del(.spec.finalizers)' \
  | $KUBECTL replace --raw "/api/v1/namespaces/$PROFILE/finalize" -f - ; \

$KUBECTL delete namespace "$PROFILE"
