#!/usr/bin/env bash

minikube_status=$(minikube status --format {{.MinikubeStatus}})
if [[ ${minikube_status} != "Running" ]]; then
  minikube start
fi
previous_context=$(kubectl config current-context)
kubectl config use-context minikube # Ensure we are working with minikube context. Idempotent.
helm init --upgrade