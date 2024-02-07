
# Configure the Azure Provider
provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

# Create Azure resource group
resource "azurerm_resource_group" "dgataz_aks_app" {
  name     = "dgataz-aks-app-resources"
  location = "UK South"
}

# Create Azure AKS cluster with 1 node
resource "azurerm_kubernetes_cluster" "dgataz_aks_app" {
  name                = "dgataz-aks-app-aks"
  location            = azurerm_resource_group.dgataz_aks_app.location
  resource_group_name = azurerm_resource_group.dgataz_aks_app.name
  dns_prefix          = "dgatazaksappaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2als_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }
}

# Configure the Kubernetes provider
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.dgataz_aks_app.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.dgataz_aks_app.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.dgataz_aks_app.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.dgataz_aks_app.kube_config.0.cluster_ca_certificate)
}

# Configure Kubernetes secret for GitHub Container Registry
resource "kubernetes_secret" "ghcr_secret" {
  metadata {
    name = "ghcr-secret"
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          auth      = "${base64encode("${var.ghcr_username}:${var.ghcr_access_token}")}"
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

# Create Kubernetes deployment with Docker container
resource "kubernetes_deployment" "dgataz_aks_app" {
  metadata {
    name = "dgataz-aks-app-deployment"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "dgataz_aks_app"
      }
    }

    template {
      metadata {
        labels = {
          app = "dgataz_aks_app"
        }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_secret.ghcr_secret.metadata[0].name
        }
        container {
          image =  "ghcr.io/${var.ghcr_username}/${var.docker_image}"
          name  = "dgataz-aks-app-container"
          
          # Expose port 80 on the container for our HTTP server
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Create a Kubernetes service to expose the nginx deployment
resource "kubernetes_service" "dgataz_aks_app" {
  metadata {
    name = "dgataz-aks-app-service"
  }

  spec {
    selector = {
      app = "dgataz_aks_app"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
