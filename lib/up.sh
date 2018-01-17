#!/usr/bin/env bash

echo -e "${G}Copying unison sync tool binaries...${NONE}"
minikube_bindir_seed="${HOME}/.minikube/files/usr/bin"
mkdir -p "${minikube_bindir_seed}"
# As VirtualBox/Hyperkit runs linux-amd64 we should copy appropriate binaries.
cp ${BASEDIR}/bin/linux-amd64/unison* $minikube_bindir_seed

if [[ "$(minikube status --format {{.MinikubeStatus}} || true)" != "Running" ]]; then
  echo -e "${G}Starting Minikube...${NONE}"
  minikube start --kubernetes-version v${KUBERNETES_VERSION} --vm-driver=${minikube_driver}
fi

echo -e "${G}Allowing root access to the Minikube node...${NONE}"
minikube ssh "sudo mkdir -p /root/.ssh"
minikube ssh "sudo chmod 700 /root/.ssh"
minikube ssh "sudo cp /home/docker/.ssh/authorized_keys /root/.ssh"
minikube ssh "sudo chown -R root:root /root/.ssh"

context_name="minikube"
echo -en "${Y}Initializing Helm... ${NONE}"
helm init --upgrade --kube-context "${context_name}" > /dev/null # Not sure if it belongs here. Should it be placed into language library part?
kubectl config use-context "${context_name}" > /dev/null # Ensure we are working with minikube context.
echo -e "${G}OK!${NONE}"

# Tiller wait workaround https://github.com/kubernetes/helm/issues/2114
# We should wait until --wait option will be available for `helm init`
# This workaround does not work! https://github.com/kubernetes/kubernetes/issues/40224
# kubectl rollout status --watch deployment/tiller-deploy --namespace=kube-system
echo -en "${Y}Rolling out Tiller deployment...${NONE}"
for i in {1..150}; do # timeout for 5 minutes
  kubectl rollout status deployment/tiller-deploy --namespace=kube-system > /dev/null
  if [ $? -eq 0 ]; then
    echo -e "${G} OK!${NONE}"
    break
  fi
  echo -en "${Y}.${NONE}"
  sleep 1
done