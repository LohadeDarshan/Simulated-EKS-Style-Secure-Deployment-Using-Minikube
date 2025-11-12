#!/bin/bash

echo "=== Setting up Prometheus & Grafana Monitoring ==="

# Add Prometheus Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack
echo "Installing kube-prometheus-stack..."
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.adminPassword=admin123 \
  --wait

echo "Waiting for all monitoring components to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s

# Port-forward Grafana
echo -e "\n=== Grafana Access ==="
echo "Username: admin"
echo "Password: admin123"
echo "Run this command to access Grafana:"
echo "kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80"
echo "Then visit: http://localhost:3000"

# Port-forward Prometheus
echo -e "\n=== Prometheus Access ==="
echo "Run this command to access Prometheus:"
echo "kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090"
echo "Then visit: http://localhost:9090"

echo -e "\n=== Creating ServiceMonitors for Custom Metrics ==="

# Create ServiceMonitor for our apps
kubectl apply -f -


echo -e "\n=== Monitoring Setup Complete ==="