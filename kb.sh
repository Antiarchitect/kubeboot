#!/usr/bin/env bash

set -o pipefail

BASEDIR=$(dirname "$0")

. ${BASEDIR}/lib/colors.sh
. ${BASEDIR}/lib/check_os.sh

os_check="Checking OS... "
echo -en "${M}${os_check}${NONE}"
for ((i=0; i < (40 - ${#os_check}); i++)){ echo -n " "; }
echo -e "${G}OK! ${C}${_os}${NONE}"

HELM_VERSION=${HELM_VERSION:-2.7.2}
MINIKUBE_VERSION=${MINIKUBE_VERSION:-0.24.1}
KUBECTL_VERSION=${KUBECTL_VERSION:-1.9.0}
KUBERNETES_VERSION=${KUBERNETES_VERSION:-1.8.0}

. ${BASEDIR}/lib/check.sh
fun_run_check

if [[ "${#PROPOSE_INSTALL[@]}" -gt 0 ]]; then
  while true; do
    echo -e "${Y}Some requirements are not met, but Kubeboot can install them. Proceed? [y/n] ${NONE}"
    read yn
    case $yn in
        [y]* ) . ${BASEDIR}/lib/install.sh; fun_run_check; break;;
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

. ${BASEDIR}/lib/up.sh

project_path="${1}"

if [ -n "${project_path}" ]; then
  CODE=${HOME}/PROJECTS
  echo "HI ${CODE} is your projects dir."

  docker build ${CODE}/docker-rails/ --tag my-rails-dev --build-arg uid=${UID}
  docker build ${CODE}/docker-postgresql-dev/ --tag my-postgresql-dev --build-arg uid=${UID}
  docker run --rm -v ${project_path}:/service:Z my-rails-dev sh -c "bundle config --local path ./vendor/bundle; bundle config --local bin ./vendor/bundle/bin"
  docker run --rm -v ${project_path}:/service:Z my-rails-dev bundle install
  eval $(minikube docker-env)

  docker build ${CODE}/docker-rails/ --tag my-rails-dev --build-arg uid=${UID}
  docker build ${CODE}/docker-postgresql-dev/ --tag my-postgresql-dev --build-arg uid=${UID}

  mkdir -p ${project_path}/.data/postgresql
  
  ${BASEDIR}/bin/$(uname | tr '[:upper:]' '[:lower:]')-amd64/unison ${project_path} ssh://root@$(minikube ip)//app \
  -sshargs "-o StrictHostKeyChecking=no -i $(minikube ssh-key)" \
  -ignorearchives \
  -owner \
  -group \
  -numericids \
  -auto \
  -batch \
  -prefer newer \
  -repeat watch \
  -ignore "Path tmp/pids" \
  &

  helm delete --purge my-rails-dev || true && helm install --name my-rails-dev ${CODE}/helm-rails
fi

minikube dashboard