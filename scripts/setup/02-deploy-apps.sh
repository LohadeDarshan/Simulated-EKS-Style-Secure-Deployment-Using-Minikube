# Create separate namespaces
kubectl create namespace app
kubectl create namespace system
kubectl create namespace monitoring

# Apply all deployments
kubectl apply -f gateway-deployment.yaml
kubectl apply -f auth-service-deployment.yaml
kubectl apply -f data-service-deployment.yaml

# Verify deployments
kubectl get pods -n app
kubectl get svc -n app
kubectl get ingress -n app

# Add gateway.local to /etc/hosts
echo "$(minikube ip) gateway.local" | sudo tee -a /etc/hosts

# Test gateway access
curl http://gateway.local