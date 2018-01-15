#!/usr/bin/env bash

set -e

declare -a PROPOSE_INSTALL=()
declare -a REQUIRED_DEPENDENCIES=()

fun_check() {
  component_name=$1
  component_version_check=$2
  is_installable=$3

  checking="Checking ${component_name}... "
  echo -en "${M}${checking}${NONE}"
  for ((i=0; i < (40 - ${#checking}); i++)){ echo -n " "; }

  version=$(${component_version_check} 2> /dev/null | head -1)
  if [ "$?" -eq "0" ]; then
    echo -e "${G}OK! ${C}${version}${NONE}"
  else
    if [ ${is_installable} ]; then
      PROPOSE_INSTALL+=("${component_name}")
      echo -e "${Y}NO! ${W}But Kubeboot is able to install ${component_name} for you!${NONE}"
    else
      REQUIRED_DEPENDENCIES+=("${component_name}")
      echo -e "${R}NO! ${W}Please install ${component_name} by yourself.${NONE}"
    fi
  fi
}

fun_check_installable() {
  fun_check "$1" "$2" "true"
}

fun_run_check() {
  case "${minikube_driver}" in
    virtualbox)
      fun_check VirtualBox "VBoxManage --version"
      ;;
    kvm2)
      fun_check KVM "qemu-kvm -version"
      ;;
    hyperkit)
      fun_check HyperKit "hyperkit -version"
      ;;
    *)
  esac

  #fun_check Docker "docker --version"
  fun_check_installable ASDF "asdf --version"
  fun_check_installable MiniKube "minikube version"
  fun_check_installable kubectl "kubectl version --client --short"
  fun_check_installable Helm  "helm version --client --short"
}

set +e