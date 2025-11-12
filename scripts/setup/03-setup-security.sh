# Send request with Authorization header to auth-service
kubectl exec -n app deployment/gateway -- curl -H "Authorization: Bearer secret-token-123" http://auth-service/headers

# Check logs for leaked credentials
kubectl logs -n app deployment/auth-service | grep "Authorization"