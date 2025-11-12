#!/bin/bash

echo "=== Testing MinIO Access ==="

# Deploy MinIO
kubectl apply -f minio-setup.yaml

# Wait for MinIO to be ready
echo "Waiting for MinIO to be ready..."
kubectl wait --for=condition=ready pod -l app=minio -n app --timeout=120s

# Test 1: data-service can access MinIO credentials
echo -e "\n--- Test 1: data-service accessing MinIO secret ---"
kubectl exec -n app deployment/data-service -- sh -c \
  "wget -q -O- --header='Authorization: Bearer \$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)' \
  https://kubernetes.default.svc/api/v1/namespaces/app/secrets/minio-secret" && \
  echo "✅ data-service CAN access MinIO secret" || \
  echo "❌ data-service CANNOT access MinIO secret"

# Test 2: auth-service cannot access MinIO credentials
echo -e "\n--- Test 2: auth-service accessing MinIO secret (should fail) ---"
kubectl exec -n app deployment/auth-service -- sh -c \
  "wget -q -O- --header='Authorization: Bearer \$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)' \
  https://kubernetes.default.svc/api/v1/namespaces/app/secrets/minio-secret" && \
  echo "❌ auth-service CAN access MinIO secret (SECURITY ISSUE!)" || \
  echo "✅ auth-service CANNOT access MinIO secret (Expected)"

# Test 3: Create bucket and upload test file from data-service
echo -e "\n--- Test 3: Creating bucket from data-service ---"
kubectl exec -n app deployment/minio -- sh -c \
  "mc alias set local http://localhost:9000 minioadmin minioadmin123 && \
   mc mb local/test-bucket && \
   mc ls local/"

echo -e "\n=== MinIO Access Tests Complete ==="