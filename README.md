# TODO
* Check if installed version of the component is lower than required. Version upgrade abiltiy.
* Cleanup. Remove all installable components along with config files.

# Up
## Minikube part
```bash
minikube delete || true && ${HOME}/PROJECTS/kubeboot/kb.sh && eval $(minikube docker-env) && docker build ${HOME}/PROJECTS/docker-rails/ --tag my-rails-dev --build-arg uid=${UID} && helm install --name my-rails-dev ../helm-rails/
```

## Unison part
```bash
~/unison ${HOME}/PROJECTS/testapp-postgresql ssh://root@$(minikube ip)//app -sshargs "-o StrictHostKeyChecking=no -i $(minikube ssh-key)" -ignorearchives -owner -group -numericids -auto -batch -repeat watch -ignore "Path tmp/pids"
```