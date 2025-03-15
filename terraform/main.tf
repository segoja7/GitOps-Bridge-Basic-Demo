provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context     = "kind-gitops-demo"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context     = "kind-gitops-demo"
  }
}

locals {
  cluster_name = "gitops-demo"
  environment  = "dev"
  gitops_repo  = "https://github.com/markbosire/gitops-repo"

  addons = {
    enable_prometheus = true  # Enable Prometheus addon
  }
  
  # Define ArgoCD applications
  argocd_apps = {
    nginx = file("${path.module}/../apps/nginx.yaml")
    prometheus = file("${path.module}/../apps/prometheus.yaml")
  }
}

module "gitops_bridge" {
  source = "gitops-bridge-dev/gitops-bridge/helm"

  cluster = {
    cluster_name = local.cluster_name
    environment  = local.environment
    metadata     = {
      repo_url  = local.gitops_repo
      repo_path = "apps"
    }
    addons       = local.addons
  }
  
  # Pass your ArgoCD applications to the module
  apps = local.argocd_apps
}