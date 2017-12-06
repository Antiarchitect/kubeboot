#!/usr/bin/env bash

set -e

declare -A PROPOSE_INSTALL=()
declare -A REQUIRED_DEPENDENCIES=()

fun_check() {
  component_name=$1
  component_version_check=$2
  is_installable=$3

  checking="Checking ${component_name}... "
  echo -en "${M}${checking}${NONE}"
  for ((i=0; i < (40 - ${#checking}); i++)){ echo -n " "; }

  version=$($2 2> /dev/null)
  if [ "$?" -eq "0" ]; then
    echo -e "${G}OK! ${C}${version}${NONE}"
  else
    if [ $is_installable ]; then
      PROPOSE_INSTALL["${component_name}"]=true
      echo -e "${Y}NO! ${W}But Kubeboot is able to install ${component_name} for you!${NONE}"
    else
      REQUIRED_DEPENDENCIES["${component_name}"]=true
      echo -e "${R}NO! ${W}Please install ${component_name} by yourself.${NONE}"
    fi
  fi
}

fun_check_installable() {
  fun_check "$1" "$2" true
}

fun_run_check() {
  fun_check VirtualBox "VBoxManage --version"
  fun_check Docker "docker --version"
  fun_check_installable ASDF "asdf --version"
  fun_check_installable MiniKube "minikube version"
  fun_check_installable kubectl "kubectl version --client --short"
  fun_check_installable Helm  "helm version --client --short"
}

set +e