#!/usr/bin/env bash

echo -e "${G}Copying unison sync tool binaries...${NONE}"
minikube_bindir_seed="${HOME}/.minikube/files/usr/bin"
mkdir -p "${minikube_bindir_seed}"
cp ${BASEDIR}/bin/unison ${BASEDIR}/bin/unison-fsmonitor $minikube_bindir_seed

if [[ "$(minikube status --format {{.MinikubeStatus}} || true)" != "Running" ]]; then
  echo -e "${G}Starting Minikube...${NONE}"
  minikube start --kubernetes-version v${KUBERNETES_VERSION}
fi

app_directory="/app"
echo -e "${G}Allowing root access to the Minikube node...${NONE}"
minikube ssh "sudo mkdir -p /root/.ssh"
minikube ssh "sudo chmod 700 /root/.ssh"
minikube ssh "sudo cp /home/docker/.ssh/authorized_keys /root/.ssh"
minikube ssh "sudo chown -R root:root /root/.ssh"
minikube ssh "sudo rm -rf ${app_directory}"
minikube ssh "sudo mkdir -p ${app_directory}"
minikube ssh "sudo chown -R ${UID}:${UID} ${app_directory}"

context_name="minikube"
echo -e "${G}Initializing Helm...${NONE}"
helm init --upgrade --kube-context "${context_name}" # Not sure if it belongs here. Should it be placed into language library part?
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator # Adding incubator repository.
kubectl config use-context "${context_name}" # Ensure we are working with minikube context.

# this for loop waits until kubectl can access the api server that Minikube has created
echo -e "${Y}Waiting Kubernetes is ready...${NONE}"
for i in {1..150}; do # timeout for 5 minutes
  kubectl get pods &> /dev/null
  if [ $? -eq 0 ]; then
    break
  fi
  sleep 1
done

# Tiller wait workaround https://github.com/kubernetes/helm/issues/2114
# We should wait until --wait option will be available for `helm init`
echo -e "${G}Rolling out Tiller deployment...${NONE}"
kubectl rollout status -w deployment/tiller-deploy --namespace=kube-system;