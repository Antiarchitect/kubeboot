#!/usr/bin/env bash

set -o pipefail

. ./bin/check.sh
if [[ "${#PROPOSE_INSTALL[@]}" -gt 0 && -z "${PROPOSE_INSTALL[ASDF]+x}" ]]; then
  . ./bin/install.sh
fi

set -e