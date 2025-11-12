#!/bin/bash

set -e

echo "=========================================="
echo "  DevOps Technical Task - Complete Setup"
echo "  Simulated EKS-Style Deployment"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[ℹ]${NC} $1"
}

# Check prerequisites
echo -e "\n=== Checking Prerequisites ==="
command -v minikube >/dev/null 2>&1 || { print_error "minikube not found. Please install it."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { print_error "kubectl not found. Please install it."; exit 1; }
command -v helm >/dev/null 2>&1 || { print_error "helm not found. Please install it."; exit 1; }

print_status "All prerequisites found"

# Start Minikube
echo -e "\n=== Starting Minikube Cluster ==="
minikube status >/dev/null 2>&1 && print_info "Minikube already running" || {
    print_info "Starting Minikube..."
    minikube start --cpus=2 --memory=4096 --addons=ingress,metrics-server
    print_status "Minikube started"
}

# Create namespaces
echo -e "\n=== Creating Namespaces ==="
kubectl create namespace app --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace system --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace kube-system name=kube-system --overwrite
print_status "Namespaces created"

# Deploy microservices
echo -e "\n=== Deploying Microservices ==="
print_info "Deploying gateway service..."
kubectl apply -f gateway-deployment.yaml
print_info "Deploying auth-service..."
kubectl apply -f auth-service-deployment.yaml
print_info "Deploying data-service..."
kubectl apply -f data-service-deployment.yaml

print_info "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/gateway -n app
kubectl wait --for=condition=available --timeout=300s deployment/auth-service -n app
kubectl wait --for=condition=available --timeout=300s deployment/data-service -n app
print_status "All microservices deployed"

# Setup hosts file for ingress
echo -e "\n=== Configuring Ingress ==="
MINIKUBE_IP=$(minikube ip)
print_info "Minikube IP: $MINIKUBE_IP"
if ! grep -q "gateway.local" /etc/hosts; then
    echo "$MINIKUBE_IP gateway.local" | sudo tee -a /etc/hosts
    print_status "Added gateway.local to /etc/hosts"
else
    print_info "gateway.local already in /etc/hosts"
fi

# Deploy MinIO
echo -e "\n=== Deploying MinIO (Mock S3) ==="
kubectl apply -f minio-setup.yaml
kubectl wait --for=condition=ready --timeout=180s pod -l app=minio -n app
print_status "MinIO deployed"

# Install Kyverno
echo -e "\n=== Installing Kyverno ==="
kubectl get namespace kyverno >/dev/null 2>&1 || {
    kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.10.0/install.yaml
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=kyverno -n kyverno --timeout=300s
    print_status "Kyverno installed"
}

# Apply security policies
echo -e "\n=== Applying Security Policies ==="
kubectl apply -f kyverno-policies.yaml
kubectl apply -f network-policies.yaml
print_status "Security policies applied"

# Setup monitoring
echo -e "\n=== Installing Prometheus & Grafana ==="
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1
helm repo update >/dev/null 2>&1

helm list -n monitoring | grep -q monitoring || {
    print_info "Installing kube-prometheus-stack..."
    helm install monitoring prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
        --set grafana.adminPassword=admin123 \
        --wait \
        --timeout 10m
    print_status "Monitoring stack installed"
}

kubectl apply -f prometheus-alerts.yaml
print_status "Prometheus alerts configured"

# Verify everything
echo -e "\n=== Verification ==="
print_info "Checking pod status..."
kubectl get pods -n app

print_info "Checking services..."
kubectl get svc -n app

print_info "Checking network policies..."
kubectl get networkpolicy -n app

print_info "Checking Kyverno policies..."
kubectl get clusterpolicy

# Access information
echo -e "\n=========================================="
echo "  Setup Complete!"
echo "=========================================="

echo -e "\n📋 ${GREEN}Quick Reference:${NC}"
echo "  Gateway URL: http://gateway.local"
echo "  Grafana: kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80"
echo "           Username: admin | Password: admin123"
echo "  Prometheus: kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090"

echo -e "\n🧪 ${YELLOW}Next Steps:${NC}"
echo "  1. Test gateway access: curl http://gateway.local"
echo "  2. Run security incident simulation: bash test-security-incident.sh"
echo "  3. Run failure simulation: bash failure-simulation.sh"
echo "  4. Access Grafana dashboard and import custom-dashboard.json"

echo -e "\n📦 ${GREEN}Deployed Components:${NC}"
kubectl get pods -n app -o wide

echo -e "\n🔐 ${GREEN}Security Status:${NC}"
kubectl get networkpolicy -n app
kubectl get clusterpolicy | grep -E "NAME|block|require|restrict"

print_status "All systems ready!"