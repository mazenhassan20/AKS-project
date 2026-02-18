# 🚀 Enterprise-Grade Cloud Infrastructure: Multi-Tier GitOps Architecture on Azure (AKS)

A high-performance, automated DevOps implementation for a Full-Stack (Node.js/React) application. This project showcases a full production lifecycle—orchestrating infrastructure via **Terraform**, managing deployments through **GitOps (ArgoCD)**, and ensuring total system visibility with a custom **Prometheus/Grafana** monitoring stack on **Azure Kubernetes Service (AKS)**.

> <img width="1908" height="976" alt="Screenshot 2026-02-17 062043" src="https://github.com/user-attachments/assets/79026419-e1fb-4668-b1e9-a24a71ca7fd0" />

---

## 🏗️ System Architecture

The project follows a modern microservices-style deployment on Azure, ensuring high availability and secure traffic routing:

* **Entry Point**: A single Azure Public IP managed by an **Nginx Ingress Controller**.
* **Routing Layer**: Path-based routing that directs traffic to the Frontend (React) or Backend (Node.js) based on the URL.
* **Security Layer**: All application pods are isolated within the cluster using `ClusterIP` services, making them inaccessible from the public internet.
* **Data Layer**: A PostgreSQL instance backed by **Azure Managed Disks** via Persistent Volume Claims (PVC) to ensure data durability.
* **Automation Layer**: GitHub Actions for CI and ArgoCD for CD/GitOps.



---

## 🛠️ The Tech Stack

| Layer | Technologies |
| :--- | :--- |
| **Infrastructure (IaC)** | Terraform |
| **Cloud Provider** | Microsoft Azure (AKS, ACR, Azure Disks) |
| **Frontend** | React.js (Nginx for Static Serving) |
| **Backend** | Node.js, Express, Prisma |
| **Database** | PostgreSQL |
| **Orchestration** | Kubernetes (K8s) |
| **CI/CD & GitOps** | GitHub Actions, ArgoCD |
| **Monitoring** | Prometheus Community Stack & Grafana |
| **Package Management** | Helm 3 |

---

## 🏗️ Step-by-Step Implementation Guide

### 1. Containerization (Docker & Local Orchestration)
The journey began by ensuring environment parity across the development lifecycle:
* **Multi-stage Docker Builds**: Optimized Frontend images by using Nginx to serve the static React build, reducing final image size significantly while improving security.
* **Docker-Compose**: Orchestrated a local development environment consisting of the Node.js API, React UI, and PostgreSQL to validate integration before cloud migration.
* **Registry Management**: Automated the tagging and pushing of production-ready images to **Azure Container Registry (ACR)** for secure, private storage.

### 2. Infrastructure as Code (Terraform)
To eliminate manual configuration and ensure reproducibility, the entire Azure environment was provisioned using **Terraform**:
* **Automated Provisioning**: Declared the AKS cluster, ACR, Resource Groups, and Networking components as code.
* **Security & Scalability**: Configured cluster identities and registry access permissions (RBAC) through Terraform variables and modules.
* **State Management**: Maintained a consistent infrastructure state, allowing for rapid environment teardown and reconstruction without manual intervention.

To ensure the infrastructure is reproducible and secure, we used **Terraform** with a **Remote Backend**:
* **Remote State Management**: Instead of storing the `terraform.tfstate` locally, it is hosted in an **Azure Blob Storage Container**. 
* **Benefits**: This prevents state loss, enables team collaboration, and ensures a "Single Source of Truth" for the infrastructure.
* **Resources**: Provisioned the AKS cluster, ACR, and the necessary networking components using modular Terraform files.

### 3. Kubernetes Orchestration & Manifests
The core application logic was deployed using declarative Kubernetes YAML manifests:
* **Deployments**: Configured high availability through managed replicas for both Frontend and Backend services.
* **Network Security**: 
    * **ClusterIP**: Implemented for internal service-to-service communication to follow the principle of least privilege.
    * **Secrets & ConfigMaps**: Decoupled application code from sensitive database credentials and environment-specific variables.

### 4. Storage & Persistence (Azure Managed Disks)
Addressing the challenge of ephemeral storage in distributed systems:
* **PVC (Persistent Volume Claim)**: Provisioned **Azure Managed Disks** to provide persistent storage for the PostgreSQL database.
* **Data Integrity**: Verified that application data remains intact across Pod restarts, node failures, and cluster updates.

### 5. Traffic Management (Ingress & Helm)
Transitioned from multiple costly LoadBalancer IPs to a consolidated, professional entry point:
* **Helm 3**: Used to deploy the **Nginx Ingress Controller** as a centralized traffic manager.
* **Path-based Routing**: Configured the Ingress to intelligently route traffic based on URL paths (`/` for UI, `/api` for the Backend API) under a single Public IP, optimizing Azure quota usage.
<img width="1061" height="77" alt="Screenshot 2026-02-17 061845" src="https://github.com/user-attachments/assets/c5120974-7250-4066-bcdb-b727986d4e9f" />

### 6. Automated CI Pipeline (GitHub Actions)
The heart of the automation, ensuring every code change is validated and built:
* **Workflow Automation**: Defined `.github/workflows` to trigger on every push to the `main` branch.
* **Build & Push**: Automated the process of building Docker images for both Frontend and Backend, and pushing them to **Azure Container Registry (ACR)** using GitHub secrets for authentication.
* **Consistency**: Guaranteed that the latest version of the application is always available in the registry for deployment.
<img width="1095" height="920" alt="Screenshot 2026-02-17 064602" src="https://github.com/user-attachments/assets/75fa229c-efa4-4519-bbda-ec95a9a43c83" />


### 7. GitOps & Automated CD
Eliminating manual intervention in the deployment process:
* **GitHub Actions**: Configured a CI pipeline that triggers on code pushes to build Docker images and update ACR.
* **ArgoCD (GitOps)**: Implemented the GitOps pattern by syncing the AKS cluster state with this repository. ArgoCD provides automated **Self-Healing**, ensuring the live environment never drifts from the defined configuration in Git.
<img width="1441" height="973" alt="Screenshot 2026-02-17 061915" src="https://github.com/user-attachments/assets/c7dfd6f4-a899-4370-bade-b352daa41188" />

### 8. Observability & Monitoring (The SRE Layer)
Achieved full transparency into the cluster's health and performance:
* **Prometheus**: Automated scraping of system and application metrics.
* **Grafana**: Built visualization dashboards for real-time monitoring of CPU, RAM, and Network utilization.
* **Node Exporter**: Deployed to collect low-level hardware metrics from the AKS nodes.
<img width="1920" height="1080" alt="Screenshot 2026-02-17 060622" src="https://github.com/user-attachments/assets/b9a81cea-a1fb-40e3-8537-0ead2c1178aa" />
<img width="1920" height="1080" alt="Screenshot 2026-02-17 060657" src="https://github.com/user-attachments/assets/66f6b565-8837-44c2-b1ae-64a9fb0c5f85" /><img width="1920" height="1080" alt="Screenshot 2026-02-17 060751" src="https://github.com/user-attachments/assets/f6cd8a30-5e24-487c-9296-4e5c7eed421c" />

---
## 🛠️ Deployment Operations (Imperative Commands)

While most of the infrastructure is declarative, some initial setup required Helm commands:

```bash
# 1. Setup Nginx Ingress
helm repo add ingress-nginx [https://kubernetes.github.io/ingress-nginx](https://kubernetes.github.io/ingress-nginx)
helm install ingress-nginx ingress-nginx/ingress-nginx --set controller.service.externalTrafficPolicy=Local

# 2. Setup Monitoring (Prometheus & Grafana)
helm repo add prometheus-community [https://prometheus-community.github.io/helm-charts](https://prometheus-community.github.io/helm-charts)
helm install monitor prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```
## 🧠 Challenges & Troubleshooting (The Engineering Reality)

* **The Ingress 404 Trap**: 
    * *Problem*: Using complex `rewrite-target` annotations caused the backend to miss the `/api` prefix it expected for internal routing.
    * *Solution*: Reverted to a **Simple Prefix** routing strategy to maintain URL consistency across the stack.
* **ArgoCD "Self-Healing" Drift**:
    * *Problem*: Manual `kubectl apply` commands were instantly reverted by ArgoCD.
    * *Solution*: Enforced a strict **Git-only workflow**, ensuring all infrastructure and application changes are committed to version control.
* **Azure Student Quota Limits**:
    * *Problem*: Faced IP exhaustion due to Azure's limit on Public Load Balancers.
    * *Solution*: Consolidated all services under one Ingress Controller to minimize IP consumption and costs.
* **Database Readiness (Race Conditions)**:
    * *Problem*: Backend services would crash if they attempted to connect before the Postgres Pod was fully ready.
    * *Solution*: Integrated an **Init Container** to wait for the database port to be open before the main application starts.

---

## 👤 Author
**Mazen Hassan**
