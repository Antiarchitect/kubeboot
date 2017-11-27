#!/usr/bin/env bash

context_name="minikube"
minikube_status=$(minikube status --format {{.MinikubeStatus}})
if [[ ${minikube_status} != "Running" ]]; then
  minikube start
fi
helm init --upgrade --kube-context "${context_name}" # Not sure if it belongs here. Should it be placed into language library part?
kubectl config use-context "${context_name}" # Ensure we are working with minikube context.