#!/usr/bin/env bash

context_name="minikube"
minikube_status=$(minikube status --format {{.MinikubeStatus}})
if [[ ${minikube_status} != "Running" ]]; then
  minikube start
fi
helm init --upgrade --kube-context "${context_name}"
kubectl config use-context "${context_name}" # Ensure we are working with minikube context.