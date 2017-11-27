#!/usr/bin/env bash

context_name="minikube"
set +e
minikube_status=$(minikube status --format {{.MinikubeStatus}})
set -e
if [[ ${minikube_status} != "Running" ]]; then
  minikube start --insecure-registry localhost:5000
fi
eval $(minikube docker-env) # Need to explore this more thoroughly.
helm init --upgrade --kube-context "${context_name}" # Not sure if it belongs here. Should it be placed into language library part?
kubectl config use-context "${context_name}" # Ensure we are working with minikube context.
kubectl apply -f ./k8s-templates/local-registry.yml