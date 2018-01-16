#!/usr/bin/env bash

set -e

declare -a PROPOSE_ASDF_INSTALL=()
declare -a PROPOSE_BREW_INSTALL=()
declare -a REQUIRED_DEPENDENCIES=()

fun_check() {
  local component_name="${1}"
  local component_version_check="${2}"
  local installer="${3}"

  checking="Checking ${component_name}... "
  echo -en "${M}${checking}${NONE}"
  for ((i=0; i < (40 - ${#checking}); i++)){ echo -n " "; }

  version=$(${component_version_check} 2> /dev/null | head -1)
  if [ "$?" -eq "0" ]; then
    echo -e "${G}OK! ${C}${version}${NONE}"
  else
    if [ "${installer}" == "asdf" ]; then
      PROPOSE_ASDF_INSTALL+=("${component_name}")
      echo -e "${Y}NO! ${W}But Kubeboot is able to install ${component_name} for you via ASDF!${NONE}"
    elif [ "${installer}" == "brew" ]; then
      PROPOSE_BREW_INSTALL+=("${component_name}")
      echo -e "${Y}NO! ${W}But Kubeboot is able to install ${component_name} for you via Brew!${NONE}"
    else
      REQUIRED_DEPENDENCIES+=("${component_name}")
      echo -e "${R}NO! ${W}Please install ${component_name} by yourself.${NONE}"
    fi
  fi
}

fun_check_asdf_installable() {
  fun_check "$1" "$2" "asdf"
}

fun_check_brew_installable() {
  fun_check "$1" "$2" "brew"
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
      fun_check_brew_installable HyperKit "hyperkit -version"
      ;;
    *)
  esac

  case "${_os}" in
    Mac)
      fun_check Homebrew "brew --version"
      fun_check_brew_installable unison-fsmonitor "which unison-fsmonitor"
      ;;
    *)
  esac

  fun_check_asdf_installable ASDF "asdf --version"
  fun_check_asdf_installable MiniKube "minikube version"
  fun_check_asdf_installable kubectl "kubectl version --client --short"
  fun_check_asdf_installable Helm "helm version --client --short"
}

set +e