````markdown
# Sonnen Task

**Author:** Khaled Mahmoud Youssef

---

## Getting Started

Clone the repository and change into the project directory:

```bash
git clone https://github.com/khaledyoussef24/SonnenSeniorTask
cd SonnenSeniorTask
```
````

## Overview

This repository contains a complete solution for deploying a custom NGINX web application to Kubernetes using Helm and Terraform, fully automated via GitHub Actions. The app serves a bespoke `index.html` page in place of the default NGINX welcome screen. You’ll find:

- A production-style Helm chart under `Charts/nginx/`
- Terraform code in `terraform/` to provision the chart in a Kubernetes cluster
- A GitHub Actions workflow (`.github/workflows/deploy.yml`) that spins up a local KinD cluster, runs Terraform, smoke-tests the service, and tears everything down

---

## Prerequisites

- **kubectl** v1.24+
- **Helm** v3+
- **Terraform** v1.4+
- **Docker** (for KinD)
- **Git** (for cloning & committing)

---

## Deploying the Helm Chart

1. **Create the namespace**
   ```bash
   kubectl create namespace nginx-app --dry-run=client -o yaml | kubectl apply -f -
   ```

````

2. **Install the chart**

   ```bash
   helm install nginx-app Charts/nginx -n nginx-app
   ```

3. **Verify rollout**

   ```bash
   helm list -n nginx-app
   kubectl rollout status deployment/nginx-app -n nginx-app --timeout=2m
   ```

---

## Testing the Application

1. **Port-forward** the service locally

   ```bash
   kubectl port-forward svc/nginx-app -n nginx-app 8080:80 &
   sleep 5
   ```

2. **Fetch the page**

   ```bash
   curl --fail http://localhost:8080
   ```

   You should see your custom HTML (e.g. `<h1>Hello from Custom NGINX Page!</h1>`).

3. **Clean up**

   ```bash
   helm uninstall nginx-app -n nginx-app
   kubectl delete namespace nginx-app
   ```

---

## Why KinD for Local Kubernetes

We selected [KinD (Kubernetes in Docker)](https://kind.sigs.k8s.io/) because it:

- **Runs clusters as Docker containers**—no VM or hypervisor overhead
- **Starts up in seconds**, ideal for local development and CI jobs
- **Matches upstream Kubernetes CI** exactly, ensuring compatibility with current APIs
- **Integrates seamlessly** with GitHub Actions, Docker, and Terraform workflows

---

## How to Run the Full Pipeline Locally

1. **Create a KinD cluster**

   ```bash
   kind create cluster --name nginx-local
   ```

2. **Set KUBECONFIG**

   ```bash
   kind get kubeconfig --name nginx-local > kind-kubeconfig
   export KUBECONFIG="$(pwd)/kind-kubeconfig"
   ```

3. **Deploy with Terraform**

   ```bash
   cd terraform
   terraform init
   terraform apply -auto-approve
   ```

4. **Smoke-test & teardown**

   ```bash
   kubectl port-forward svc/nginx-app -n nginx-app 8080:80 &
   sleep 5
   curl http://localhost:8080
   terraform destroy -auto-approve
   kind delete cluster --name nginx-local
   ```

---

## Improvements & Next Steps

### 1. Multi-Environment Deployments

- Maintain separate values files for each environment (e.g. `values-prod.yaml`, `values-staging.yaml`, `values-test.yaml`)
- Use Git branches, Helmfile, or Terraform workspaces to drive environment-specific deployments

### 2. Ingress Routing

Add an `ingress.yaml` template to expose the service under a hostname and TLS:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  namespace: nginx-app
spec:
  rules:
    - host: nginx.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-app
                port:
                  number: 80
```

### 3. Horizontal Pod Autoscaling

Include `hpa.yaml` to scale pods based on CPU utilization:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
  namespace: nginx-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-app
  minReplicas: 1
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

### 4. Observability with Prometheus & Grafana

- Deploy a Prometheus server to scrape NGINX metrics (via the Prometheus NGINX exporter)
- Install Grafana and import dashboards for CPU, memory, request rates, and error rates
- Define Alertmanager rules for high latency, 5xx spikes, or pod restarts

---
````
