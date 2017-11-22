#!/usr/bin/env bash

declare -A PROPOSE_INSTALL=()

fun_check() {
  checking="Checking $1... "
  echo -en "${Y}${checking}${NONE}"
  for ((i=0; i < (40 - ${#checking}); i++)){ echo -n " "; }

  version=$($2 2> /dev/null)
  if [ "$?" -eq "0" ]; then
    echo -e "${G}OK! ${C}${version}${NONE}"
  else
    PROPOSE_INSTALL["$1"]=true
    echo -e "${R}NO! ${W}Please install $1 first.${NONE}"
  fi
}

fun_asdf() {
  fun_check ASDF "asdf --version"
}

fun_docker() {
  fun_check Docker "docker --version"
}

fun_virtualbox() {
  fun_check VirtualBox "VBoxManage --version"
}

fun_minikube() {
  fun_check MiniKube "minikube version"
}

fun_kubectl() {
  fun_check kubectl "kubectl version --client --short"
}

fun_helm() {
  fun_check Helm  "helm version --client --short"
}

fun_run_check() {
  fun_asdf
  fun_docker
  fun_virtualbox
  fun_minikube
  fun_kubectl
  fun_helm
}
