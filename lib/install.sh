#!/usr/bin/env bash

set -e

echo "Hi! Mr. Install speaking! I will help you to install some packages. Hold on!"
HELM_VERSION=2.7.2
MINIKUBE_VERSION=0.23.0
KUBECTL_VERSION=1.8.4

fun_asdf_install() {
  local plugin_name=$1
  local plugin_version=$2
  local plugin_source=$3

  if [[ $(asdf plugin-list | grep -w "${plugin_name}" | wc -l) -eq 0 ]]; then
    asdf plugin-add "${plugin_name}" "${plugin_source}"
  fi
  if [[ $(asdf list-all "${plugin_name}" | grep -w "${plugin_version}" | wc -l) -eq 0 ]]; then
    echo "There is no ${plugin_version} version for ${plugin_name}!"
    exit 1;
  fi
  asdf install "${plugin_name}" "${plugin_version}" # Idempotent
  asdf global "${plugin_name}" "${plugin_version}"
}

if [[ "${PROPOSE_INSTALL[Helm]}" = true ]]; then
  fun_asdf_install helm "${HELM_VERSION}" https://github.com/Antiarchitect/asdf-helm.git
fi

if [[ "${PROPOSE_INSTALL[MiniKube]}" = true ]]; then
  fun_asdf_install minikube "${MINIKUBE_VERSION}"
fi

if [[ "${PROPOSE_INSTALL[kubectl]}" = true ]]; then
  fun_asdf_install kubectl "${KUBECTL_VERSION}"
fi

set +e