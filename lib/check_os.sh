#!/usr/bin/env bash

set -e

case "$(uname -s)" in
    Linux*)     _os=Linux;;
    Darwin*)    _os=Mac;;
    CYGWIN*)    _os=Cygwin;;
    MINGW*)     _os=MinGw;;
    *)          _os="UNKNOWN"
esac

case "${_os}" in
  Linux)
    unison_platform="linux-amd64"
    minikube_driver="${LINUX_MINIKUBE_DRIVER}"
    ;;
  Mac)
    unison_platform="darwin-amd64"
    minikube_driver="hyperkit"
    ;;
  *)
esac