#!/usr/bin/env bash

set -o pipefail

. ./lib/colors.sh

. ./lib/check.sh
fun_run_check

if [[ "${#PROPOSE_INSTALL[@]}" -gt 0 ]]; then
  while true; do
    read -p "There are some requirements that are not met, but I can help you install them. Proceed? [y/n]" yn
    case $yn in
        [y]* ) . ./lib/install.sh; fun_run_check; break;;
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

. ./lib/up.sh

minikube dashboard