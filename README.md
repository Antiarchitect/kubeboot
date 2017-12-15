# TODO
* Check if installed version of the component is lower than required. Version upgrade abiltiy.
* Cleanup. Remove all installable components along with config files.

# Up
Install docker and VirtualBox by yourself.
Replace your `${HOME}/PROJECTS` in commands below to your projects/code directory path.

## Repos you need to clone:
git clone https://github.com/Antiarchitect/kubeboot.git
git clone https://github.com/Antiarchitect/docker-rails.git
git clone https://github.com/Antiarchitect/helm-rails.git

## Minikube part
```bash
minikube delete || true && ${HOME}/PROJECTS/kubeboot/kb.sh && eval $(minikube docker-env) && docker build ${HOME}/PROJECTS/docker-rails/ --tag my-rails-dev --build-arg uid=${UID}
```

## Create test application
```bash
docker build . --tag my-rails-dev-bootstrap --build-arg uid=${UID} --build-arg rails_version=5.1.4
docker run --rm -v ${HOME}/PROJECTS:/service:Z my-rails-dev-bootstrap rails new testapp-postgresql --database postgresql
docker run --rm -v ${HOME}/PROJECTS:/service:Z my-rails-dev sh -c "bundle config --local path ./vendor/bundle; bundle config --local bin ./vendor/bundle/bin"
docker run --rm -v ${HOME}/PROJECTS:/service:Z my-rails-dev bundle install
```

## Unison part (separate terminal - it won't release it)
```bash
${HOME}/PROJECTS/kubeboot/bin/unison ${HOME}/PROJECTS/testapp-postgresql ssh://root@$(minikube ip)//app -sshargs "-o StrictHostKeyChecking=no -i $(minikube ssh-key)" -ignorearchives -owner -group -numericids -auto -batch -repeat watch -ignore "Path tmp/pids"
```

## Helm install part
```bash
helm install --name my-rails-dev ${HOME}/PROJECTS/helm-rails
```