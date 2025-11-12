# Start Minikube cluster
minikube start --cpus=2 --memory=4096 --addons=ingress,metrics-server

# Verify cluster is running
kubectl cluster-info
kubectl get nodes