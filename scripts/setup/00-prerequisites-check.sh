#!/bin/bash
# Prerequisites check script
echo "Checking prerequisites..."
command -v minikube >/dev/null 2>&1 || { echo "minikube not found"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl not found"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "helm not found"; exit 1; }
echo "✓ All prerequisites found"
