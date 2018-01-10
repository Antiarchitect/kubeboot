# TODO
* Check if installed version of the component is lower than required. Version upgrade abiltiy.
* Cleanup. Remove all installable components along with config files.

# Example of running Rails app with PostgreSQL support within local Kubernetes cluster on Minikube.

## Prerequisites
Install VirtualBox (Linux) or Hyperkit (MacOS) by yourself.

## Clone test application

Assume your projects path is 
```bash
cd ~/PROJECTS && clone https://github.com/Antiarchitect/testapp-postgresql.git
```

## Run kubeboot
```bash
~/PROJECTS/kubeboot/kb.sh ~/PROJECTS/testapp-postgresql/
```

## Kubernetes dashboard
It should open up automatically, but you can easily access it by typing:
```bash
minikube dashboard
```

## Know your app url:
```bash
export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services my-rails-dev-helm-rails)
export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
```
