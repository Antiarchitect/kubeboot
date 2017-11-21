#!/usr/bin/env bash

set -e

echo "Hi! Mr. Install speaking! I will help you to install some packages. Hold on!"

if [[ "${PROPOSE_INSTALL[Helm]}" = true ]]; then
  asdf plugin-add helm https://github.com/Antiarchitect/asdf-helm.git
fi
