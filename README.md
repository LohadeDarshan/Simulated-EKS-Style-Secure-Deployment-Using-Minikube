
# 🛡️ Simulated EKS-Style Secure Deployment Using Minikube

This project demonstrates a simulated secure microservices deployment using Minikube, mimicking real-world AWS EKS practices. It focuses on infrastructure, security, observability, and incident response.

---

## 📦 Setup Instructions

### ✅ Prerequisites

- Minikube
- Docker
- kubectl
- helm
- (Optional) k9s, Kyverno, OPA, Falco

### ✅ Start Minikube

```bash
minikube start --cpus=2 --memory=4096 --addons=ingress,metrics-server
```

### ✅ Deploy Services

Each service is containerized via Helm charts:

```bash
cd charts/gateway && helm install gateway .
cd charts/auth-service && helm install auth-service .
cd charts/data-service && helm install data-service .
```

### ✅ Deploy MinIO

```bash
kubectl apply -f manifests/minio/
```

### ✅ Apply Network Policies and RBAC

```bash
kubectl apply -f manifests/network-policies/
```

### ✅ Deploy OPA/Kyverno/Falco Policies

```bash
kubectl apply -f manifests/opa/
```

### ✅ Setup Monitoring

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack
```

---

## 🧱 Architecture Diagram

```
                      +-------------+
                      |   Ingress   |
                      +------+------+
                             |
                      +------+------+
                      |   Gateway    |  (Public)
                      +------+------+
                             |
              +--------------+--------------+
              |                             |
      +-------+--------+           +--------+--------+
      |   Auth Service  | -------> |   Data Service   |
      +-----------------+          +------------------+
                |
          +-----+------+
          |   MinIO    |
          +------------+
```

---

## 🎯 Design Decisions

- **Namespace Isolation**: `system` and `app` separated for clarity and RBAC boundaries.
- **Ingress**: NGINX ingress for production-like traffic routing.
- **Resource Limits**: All pods have `resources.limits` and `resources.requests`.
- **Service Access**: `gateway` is public, others are cluster-internal.
- **MinIO + RBAC**: Simulated IAM using service accounts + secret.

---

## 🚨 Security Incident & Fix

### 🔍 Problem

- `auth-service` was logging incoming `Authorization` headers.
- It was also able to call arbitrary external services — a violation.

### 🛠️ Fixes

- `/headers` calls were blocked from receiving sensitive headers.
- NetworkPolicy applied:
  - Allow only `auth-service -> data-service`
  - Block all other egress

### 🔐 Prevent Future Issues

- Added OPA/Kyverno policy to detect and alert on `Authorization` headers being logged.
- Future violations can be caught by runtime tools (e.g., Falco).

---

## 📊 Observability

- Prometheus + Grafana deployed
- Dashboard includes:
  - Pod CPU/memory
  - HTTP request rates & errors
  - Pod restarts

> Exported dashboard JSON is included in `grafana-dashboards/eks-dashboard.json`

---

## ⚠️ Failure Simulation

- Deleted pods using `kubectl delete pod`
- Verified system auto-recovered using ReplicaSet
- Monitored restart spike in Grafana
- Created alert rules for crash loops & failed probes

---

## 📝 Assumptions / Known Issues

- MinIO credentials are in a simple Kubernetes Secret (not sealed).
- Simulated IAM via ServiceAccounts only.
- OPA is enforcing a basic rule — real policies would require auditing.

---

## ✅ Deliverables

- ✅ `README.md` (this file)
- ✅ `charts/` (Helm for each service)
- ✅ `manifests/` (YAML for MinIO, RBAC, NetworkPolicies)
- ✅ `grafana-dashboards/` (exported dashboard JSON)
- ✅ Architecture diagram (ASCII above)
- ✅ OPA policy files
