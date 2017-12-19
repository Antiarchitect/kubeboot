#!/usr/bin/env bash

set -o pipefail

BASEDIR=$(dirname "$0")

. ${BASEDIR}/lib/colors.sh
. ${BASEDIR}/lib/check_os.sh

os_check="Checking OS... "
echo -en "${M}${os_check}${NONE}"
for ((i=0; i < (40 - ${#os_check}); i++)){ echo -n " "; }
echo -e "${G}OK! ${C}${_os}${NONE}"

HELM_VERSION=${HELM_VERSION:-2.7.2}
MINIKUBE_VERSION=${MINIKUBE_VERSION:-0.24.1}
KUBECTL_VERSION=${KUBECTL_VERSION:-1.9.0}
KUBERNETES_VERSION=${KUBERNETES_VERSION:-1.8.0}

. ${BASEDIR}/lib/check.sh
fun_run_check

if [[ "${#PROPOSE_INSTALL[@]}" -gt 0 ]]; then
  while true; do
    echo -e "${Y}Some requirements are not met, but Kubeboot can install them. Proceed? [y/n] ${NONE}"
    read yn
    case $yn in
        [y]* ) . ${BASEDIR}/lib/install.sh; fun_run_check; break;;
        [n]* ) exit;;
        * ) echo "Please answer y or n.";;
    esac
  done
fi

if [[ "${#REQUIRED_DEPENDENCIES[@]}" -gt 0 ]]; then
  echo -e "${R}You have some dependencies Kubeboot cannot resolve. Please install required components by yourself.${NONE}"
  exit
fi

set -e

. ${BASEDIR}/lib/up.sh

minikube dashboard