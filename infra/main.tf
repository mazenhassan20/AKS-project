terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"       
    storage_account_name = "mazentfstate9988" 
    container_name       = "tfstate"           
    key                  = "terraform.tfstate" 
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = "my-devops-project-rg"
}

data "azurerm_container_registry" "acr" {
  name                = "mazenelsayad1234"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "my-aks-cluster"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "myaks"

  default_node_pool {
    name       = "default"
    node_count = 1               
    vm_size    = "Standard_B2s_v2" 
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = data.azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# 5. طباعة اسم الكلاستر والداتا بتاعته بعد ما يخلص
output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}
