# DevOps EKS-Style Deployment on Minikube

[![CI Pipeline](https://img.shields.io/badge/CI-passing-brightgreen.svg)]()
[![Kubernetes](https://img.shields.io/badge/kubernetes-v1.27+-blue.svg)](https://kubernetes.io)
[![Helm](https://img.shields.io/badge/helm-v3.12+-blue.svg)](https://helm.sh)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

> A production-grade simulation of AWS EKS deployment patterns using Minikube, focusing on security, observability, and incident response.

## 🎯 Overview

This project demonstrates enterprise-level DevOps practices by simulating a secure microservices deployment in a local Kubernetes cluster. It includes:

- 🔐 Network policies and RBAC for security
- 📊 Complete observability with Prometheus & Grafana
- 🛡️ Policy enforcement with Kyverno
- 🚨 Incident response scenarios
- 🧪 Chaos engineering tests
- 📦 Infrastructure as Code

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         Ingress Controller              │
└────────────────┬────────────────────────┘
                 │
         ┌───────▼────────┐
         │    Gateway     │
         └───────┬────────┘
                 │
         ┌───────▼────────┐
         │  Auth Service  │
         └───────┬────────┘
                 │
         ┌───────▼────────┐
         │  Data Service  │
         └───────┬────────┘
                 │
         ┌───────▼────────┐
         │  MinIO (S3)    │
         └────────────────┘
```

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/yourusername/devops-eks-minikube-simulation.git
cd devops-eks-minikube-simulation

# Run complete setup
chmod +x scripts/setup/*.sh
./scripts/setup/complete-setup.sh

# Verify deployment
kubectl get pods -n app

# Access Grafana
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```

## 📚 Documentation

- [Setup Guide](docs/SETUP-GUIDE.md)
- [Architecture Details](docs/ARCHITECTURE.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Security Analysis](docs/SECURITY-ANALYSIS.md)
- [Testing Checklist](TESTING-CHECKLIST.md)

## 🔧 Prerequisites

- Minikube >= v1.30
- kubectl >= v1.27
- Helm >= v3.12
- Docker >= 20.10

## 📦 Components

| Component | Version | Purpose |
|-----------|---------|---------|
| Gateway | latest | API Gateway (NGINX) |
| Auth Service | latest | Authentication (HTTPBin) |
| Data Service | latest | Business Logic |
| MinIO | latest | S3-compatible storage |
| Prometheus | latest | Metrics collection |
| Grafana | latest | Visualization |
| Kyverno | v1.10.0 | Policy enforcement |

## 🧪 Testing

```bash
# Run all tests
./scripts/testing/test-deployments.sh
./scripts/testing/test-security-incident.sh
./scripts/testing/failure-simulation.sh
```

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/LohadeDarshan)
- LinkedIn: [Your LinkedIn](https://www.linkedin.com/in/darshan-lohade-754263259)

## ⭐ Show Your Support

Give a ⭐️ if this project helped you!
