terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # 👇👇 ده الجزء الجديد اللي هينقل الملف لأزور 👇👇
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"        # اسم الجروب الخاص بالـ State
    storage_account_name = "mazentfstate9988"  # اسم الستورج اللي عملناه (تأكد إنه نفس الاسم اللي عملته)
    container_name       = "tfstate"           # اسم الحاوية
    key                  = "terraform.tfstate" # اسم الملف
  }
}

provider "azurerm" {
  features {}
}

# 1. استدعاء الـ Resource Group الموجودة مسبقاً
data "azurerm_resource_group" "rg" {
  name = "my-devops-project-rg"
}

# 2. استدعاء الـ ACR الموجود مسبقاً (عشان نربطه بالـ AKS)
data "azurerm_container_registry" "acr" {
  name                = "mazenelsayad1234" # اسم الـ ACR بتاعك
  resource_group_name = data.azurerm_resource_group.rg.name
}

# 3. إنشاء الـ AKS Cluster (السيرفر الرئيسي)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "my-aks-cluster"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "myaks"

  default_node_pool {
    name       = "default"
    node_count = 1                # نود واحدة كفاية للتجربة والتوفير
    vm_size    = "Standard_B2s_v2" # تأكد إن المقاس ده متاح في region النمسا
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }
}

# 4. إعطاء صلاحية للـ AKS إنه يسحب صور من الـ ACR (AcrPull)
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
