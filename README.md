# GitOps Demo with ArgoCD

This repository demonstrates a GitOps workflow using ArgoCD, Terraform, and Kubernetes. The demo includes deployment of Nginx and Prometheus monitoring stack in a local Kind cluster.

## Prerequisites

- [Git](https://git-scm.com/downloads)
- [Docker](https://docs.docker.com/get-docker/)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)


## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/markbosire/gitops-repo.git
cd gitops-repo
```

### 2. Create a Kind Cluster

```bash
kind create cluster --name gitops-demo
```

Verify the cluster is running:

```bash
kubectl cluster-info --context kind-gitops-demo
```

### 3. Initialize Terraform

Navigate to the Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

This will download the necessary providers and modules.

### 4. Deploy with Terraform

Apply the Terraform configuration:

```bash
terraform apply
```

Review the planned changes and type `yes` when prompted to proceed.

The deployment will:
- Install ArgoCD in your Kind cluster
- Configure ArgoCD to monitor your GitOps repository
- Deploy Nginx application
- Deploy Prometheus monitoring stack (kube-prometheus-stack)

### 5. Access ArgoCD UI

First, list the services in the ArgoCD namespace to find the server service name:

```bash
kubectl get svc -n argocd
```

Port-forward the ArgoCD server (in my case, the service name is argo-cd-argocd-server):

```bash
kubectl port-forward svc/argo-cd-argocd-server -n argocd 8080:443
```

Access the ArgoCD UI at: https://localhost:8080

Default login credentials (unless changed):
- Username: admin
- Password: (Get the password by running the command below)

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

### 6. Verify Deployments

Wait for all the applications to finish deploying.
Check that your applications are successfully deployed:

```bash
kubectl get applications -n argocd
```

Access Nginx:

```bash
kubectl port-forward svc/nginx 8090:80
```

Then visit http://localhost:8090 in your browser.

Access Prometheus:

First, list the services in the monitoring namespace to find the server service name:

```bash
kubectl get svc -n monitoring | grep 9090
```

Port-forward the prometheus (in my case, the service name is kube-prometheus-stack-gito-prometheus):

```bash
# Port-forward the prometheus service (adjust service name if needed)
kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090
```

Then visit http://localhost:9090 in your browser.

Access Grafana:

```bash
# First check the service name
kubectl get svc -n monitoring | grep grafana

# Port-forward the Grafana service (adjust service name if needed)
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80
```

Then visit http://localhost:3000 in your browser.

Default Grafana credentials (unless changed):
- Username: admin
- Password: prom-operator

You could check the resource metrics by searching kubernetes and clicking the resource you want to monitor

## Project Structure

```
gitops-repo/
├── apps/
│   ├── nginx.yaml      # ArgoCD Application for Nginx
│   └── addons.yaml     # ArgoCD ApplicationSet for addons
├── addons/             # GitOps configuration for addons
├── terraform/          # Terraform configuration
│   └── main.tf         # Main Terraform configuration
└── README.md           # This file
```

## Customization

To customize the deployment, modify the following files:
- `terraform/main.tf`: Update the locals section to change configuration
- `apps/*.yaml`: Modify ArgoCD application definitions
- `addons/`: Update addon configurations

## Cleanup

To delete all resources and the Kind cluster:

```bash
terraform destroy
kind delete cluster --name gitops-demo
```