
# Configure the Azure Provider
provider "azurerm" {
  # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  skip_provider_registration = true
  features {}

  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

# Create a resource group
resource "azurerm_resource_group" "dgataz_aks_app" {
  name     = "dgataz-aks-app-resources"
  location = "UK South"
}

resource "azurerm_kubernetes_cluster" "dgataz_aks_app" {
  name                = "dgataz-aks-app-aks"
  location            = azurerm_resource_group.dgataz_aks_app.location
  resource_group_name = azurerm_resource_group.dgataz_aks_app.name
  dns_prefix          = "dgatazaksappaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2pls_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }
}
