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
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator # Adding incubator repository.
kubectl config use-context "${context_name}" # Ensure we are working with minikube context.

if [[ $(helm list --all --short | fgrep local-docker-registry | wc -l) == 0 ]]; then
  helm install incubator/docker-registry --name local-docker-registry
fi

if [[ $(helm list --all --short | fgrep local-prometheus | wc -l) == 0 ]]; then
  helm install stable/prometheus --name local-prometheus
fi