# TODO
* Check if installed version of the component is lower than required. Version upgrade abiltiy.
* Cleanup. Remove all installable components along with config files.

# Example of running Rails app with PostgreSQL support within local Kubernetes cluster on Minikube.

## Prerequisites
Install VirtualBox (Linux) or Hyperkit (MacOS) by yourself.

## Test application

###  Clone it

Assume your projects path is `~/PROJECTS`
```console
cd ~/PROJECTS && clone https://github.com/Antiarchitect/testapp-postgresql.git
```

### Initialize submodules
```console
cd ~/PROJECTS/testapp-postgresql/
git submodule init
git submodule update --remote
```

## Run kubeboot
```console
~/PROJECTS/kubeboot/kb.sh ~/PROJECTS/testapp-postgresql/
```

## Kubernetes dashboard
It should open up automatically, but you can easily access it by typing:
```console
minikube dashboard
```

## Know your app url:
```console
export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services my-rails-dev-helm-rails)
export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
```

# Application internals

## kubeboot.yaml
`kubeboot.yaml` is a simple config file stored on the app side to tell kubeboot some specifics about your app you want
to run inside the local kubernetes cluster.

### Parameters
| Parameter                 | Description                                                                             |
|---------------------------|-----------------------------------------------------------------------------------------|
| `app_image_tag`           | Docker image with your application runtime. Will be used to name Helm release.          |
| `dockerfiles`             | Array of hashes with all docker images to be built from your `.dockerfiles`.            | 
| `sync_precreate_paths`    | Paths that should be precreated before sync with correct permissions                    |
| `sync_ignored_paths`      | Paths in application directory that should not be synced. `tmp/pids` is a good example. |

## .dockerfiles
Is the place all your service-related dockerfiles for development are located in.

## .helm
Is your application Helm chart.                                                                                                                      