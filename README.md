# Requirements
- docker
- minikube
- kubectl
- terraform

# Demo
```bash
# setup minikube
minikube start --kubernetes-version=1.24.3 --driver=docker --memory 8192 --cpus 2

# setup consul
terraform -chdir=consul init
terraform -chdir=consul apply # yes

# port-forward for consul service intention and ui
kubectl port-forward -n consul services/consul-server --address localhost 8500:8500 &

# start the app
terraform -chdir=hashicups init
terraform -chdir=hashicups apply # yes

# access the app
kubectl port-forward $(kubectl get pod -l app=nginx -o jsonpath="{.items[0].metadata.name}") 8080:80 &

# open localhost:8500 for consul ui
# open localhost:8080 for hashicups
```