# TODO
* Check if installed version of the component is lower than required. Version upgrade abiltiy.
* Cleanup. Remove all installable components along with config files.

# Example of running Rails app with PostgreSQL support within local Kubernetes cluster on Minikube.

## Prerequisites
Install docker and VirtualBox by yourself.
For convenience you should assign `${CODE}` variable pointing to the path of your code/projects directory. You can place it in your .bashrc,
ensure however that `${CODE}` variable is not in use for something important already.

Example:
```bash
echo -e 'CODE=${HOME}/PROJECTS' >> "${HOME}/.bashrc" # Replace ${HOME}/PROJECTS to your actual code directory.
source "${HOME}/.bashrc"
```

## Repos you need to clone for this example:
Clone the repos below to your projects directory.
```bash
cd ${CODE}
git clone https://github.com/Antiarchitect/kubeboot.git 
git clone https://github.com/Antiarchitect/docker-rails.git
git clone https://github.com/Antiarchitect/docker-postgresql-dev.git # If you need PostgreSQL in you Project.
git clone https://github.com/Antiarchitect/helm-rails.git
```

## Minikube part
```bash
minikube stop || true && ${CODE}/kubeboot/kb.sh
```

## Building images within Minikube docker context
```bash
eval $(minikube docker-env)
docker build ${CODE}/docker-rails/ --tag my-rails-dev --build-arg uid=${UID}
docker build ${CODE}/docker-postgresql-dev/ --tag my-postgresql-dev --build-arg uid=${UID}
```

## Clone test application

```bash
cd ${CODE} && git clone https://github.com/Antiarchitect/testapp-postgresql.git
```

## ... or create it by yourself
**Important!** Open new terminal to avoid Minikube Docker context.
```bash
docker build . --tag my-rails-dev-bootstrap --build-arg uid=${UID} --build-arg rails_version=5.1.4
docker run --rm -v ${CODE}:/service:Z my-rails-dev-bootstrap rails new testapp-postgresql --database postgresql
docker run --rm -v ${CODE}/testapp-postgresql:/service:Z my-rails-dev sh -c "bundle config --local path ./vendor/bundle; bundle config --local bin ./vendor/bundle/bin"
docker run --rm -v ${CODE}/testapp-postgresql:/service:Z my-rails-dev bundle install
```

## Sync workdir into the VM
**Important!** For simplicity of the setup we will have one synchronized Persistent Volume so all subpaths
(e.g. database data directory inside your Rails project should be created manually on your dev machine before the sync).
For example for postgresql database run this on your development machine:
```bash
mkdir -p ${CODE}/testapp-postgresql/.data/postgresql
```

## Unison
### Prerequisites
Add unison binaries to your local bin directory (platform specific - check needed):
```bash
cp ${CODE}/kubeboot/bin/$(uname | tr '[:upper:]' '[:lower:]')-amd64/unison ${HOME}/bin
``` 

### Sync (do in standalone terminal window)
```bash
unison ${CODE}/testapp-postgresql ssh://root@$(minikube ip)//app -sshargs "-o StrictHostKeyChecking=no -i $(minikube ssh-key)" -ignorearchives -owner -group -numericids -auto -batch -prefer newer -repeat watch -ignore "Path tmp/pids"
```

## Helm install part
```bash
helm delete --purge my-rails-dev || true && helm install --name my-rails-dev ${CODE}/helm-rails
```

## Know your app url:
```bash
export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services my-rails-dev-helm-rails)
export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
```
