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
KUBECTL_VERSION=${KUBECTL_VERSION:-1.9.1}
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

eval project_path="${1}"

if [ -n "${project_path}" ]; then
  . ${BASEDIR}/lib/yaml_parser.sh

  eval $(parse_yaml ${project_path}/kubeboot.yaml "config_")

  helm delete --purge "${config_app_image_tag}" || true

  for subdir in "${config_sync_subdirs[@]}";
  do
    mkdir -p "${project_path}/${subdir}"
  done

  primary_group=$(id -g)
  app_directory="/app"
  minikube ssh "sudo rm -rf ${app_directory}"
  minikube ssh "sudo mkdir -p ${app_directory}"
  minikube ssh "sudo chown -R ${UID}:${primary_group} ${app_directory}"

  ignore_string=""
  for ignored in "${config_sync_ignored_paths[@]}";
  do
    ignore_string="${ignore_string}-ignore 'Path ${ignored}' "
  done

  ${BASEDIR}/bin/${unison_platform}/unison ${project_path} ssh://root@$(minikube ip)//app \
  -sshargs "-o StrictHostKeyChecking=no -i $(minikube ssh-key)" \
  -ignorearchives \
  -owner \
  -group \
  -numericids \
  -auto \
  -batch \
  -prefer newer \
  -fastcheck true \
  $(eval ${ignore_string})

  ${BASEDIR}/bin/${unison_platform}/unison ${project_path} ssh://root@$(minikube ip)//app \
  -sshargs "-o StrictHostKeyChecking=no -i $(minikube ssh-key)" \
  -ignorearchives \
  -owner \
  -group \
  -numericids \
  -auto \
  -batch \
  -prefer newer \
  -fastcheck true \
  -repeat 1 \
  $(eval ${ignore_string}) &

  unison_pid=$!

  for i in "${!config_dockerfiles__path[@]}";
  do
    dockerfiles_path="/app/${config_dockerfiles__path[$i]}"
    dockerfiles_tag=${config_dockerfiles__tag[$i]}
    minikube ssh "docker build ${dockerfiles_path} --tag ${dockerfiles_tag} --build-arg uid=${UID} --build-arg gid=${primary_group}"
  done

  # Bundler
  if [ -f "${project_path}/Gemfile.lock" ]; then
    minikube ssh "docker run --rm -v /app:/service:Z ${config_app_image_tag} sh -c 'bundle config --local path ./vendor/bundle && bundle config --local bin ./vendor/bundle/bin && bundle install'"
  fi

  helm install --name "${config_app_image_tag}" "${project_path}/.helm"

  wait ${unison_pid}
fi

minikube dashboard