#!/usr/bin/env bash

set -o pipefail

. ./lib/colors.sh

. ./lib/check.sh
fun_run_check

if [[ "${#PROPOSE_INSTALL[@]}" -gt 0 ]]; then
  . ./lib/install.sh
  fun_run_check
fi

set -e

. ./lib/up.sh

minikube dashboard