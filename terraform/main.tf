######################
#   Resource Groups  #
######################

resource "azurerm_resource_group" "vnet-rg" {
  name     = "${var.prefix}-${var.vnet_rg_name}-rg"
  location = var.location

  tags = var.tags
}

resource "azurerm_resource_group" "aks-rg" {
  name     = "${var.prefix}-${var.aks_rg_name}-rg"
  location = var.location

  tags = var.tags
}

######################
#   Virtual Network  #
######################

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-${var.vnet_name}-vn"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.vnet-rg.name

  tags = var.tags
}

######################
#       Subnet       #
######################

resource "azurerm_subnet" "aks-subnet" {
  name                 = var.aks_subnet_name
  resource_group_name  = azurerm_resource_group.vnet-rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.aks_subnet_prefix

  service_endpoints = ["Microsoft.KeyVault"]
}

######################
#     AKS Cluster    #
######################
resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = "${var.prefix}-${var.aks_name}-aks"
  location            = azurerm_resource_group.aks-rg.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  dns_prefix          = var.aks_name
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                         = "agentpool"
    node_count                   = var.aks_agent_count
    vm_size                      = "Standard_DS2_v2"
    vnet_subnet_id               = azurerm_subnet.aks-subnet.id
    type                         = "VirtualMachineScaleSets"
    only_critical_addons_enabled = true
  }

  addon_profile {
    kube_dashboard {
      enabled = false
    }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks-ws.id
    }
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = "azure"
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
    load_balancer_sku  = "Standard"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "aks-cluster-userpool" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-cluster.id
  node_count            = var.aks_agent_count
  vm_size               = "Standard_DS2_v2"
  vnet_subnet_id        = azurerm_subnet.aks-subnet.id
  type                  = "VirtualMachineScaleSets"
  mode                  = "User"

  tags = var.tags
}

resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

######################
#    Log Analytics   #
######################

resource "azurerm_log_analytics_workspace" "aks-ws" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${var.prefix}-monitor-${random_id.log_analytics_workspace_name_suffix.dec}-ws"
  location            = var.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  sku                 = "PerGB2018"

  tags = var.tags
}

resource "azurerm_log_analytics_solution" "aks-ws-solution" {
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = azurerm_resource_group.aks-rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.aks-ws.id
  workspace_name        = azurerm_log_analytics_workspace.aks-ws.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

######################
#      Key Vault     #
######################

resource "azurerm_key_vault" "aks-kv" {
  name                        = "${var.prefix}-${var.key_vault_name}-kv"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.aks-rg.name
  enabled_for_disk_encryption = false
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = true

  sku_name = "standard"

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [azurerm_subnet.aks-subnet.id]
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "kv-reader-kubelet" {
  scope                            = azurerm_key_vault.aks-kv.id
  role_definition_name             = "Key Vault Reader"
  principal_id                     = azurerm_kubernetes_cluster.aks-cluster.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "kv-reader-agentpool" {
  scope                            = azurerm_key_vault.aks-kv.id
  role_definition_name             = "Key Vault Reader"
  principal_id                     = azurerm_kubernetes_cluster.aks-cluster.identity[0].principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "kv-secrets-user-kubelet" {
  scope                            = azurerm_key_vault.aks-kv.id
  role_definition_name             = "Key Vault Secrets User"
  principal_id                     = azurerm_kubernetes_cluster.aks-cluster.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "kv-secrets-user-agentpool" {
  scope                            = azurerm_key_vault.aks-kv.id
  role_definition_name             = "Key Vault Secrets User"
  principal_id                     = azurerm_kubernetes_cluster.aks-cluster.identity[0].principal_id
  skip_service_principal_aad_check = true
}

######################
# Container Registry #
######################

resource "azurerm_container_registry" "acr" {
  name                = "${var.acr_name}${random_id.acr_suffix.dec}acr"
  resource_group_name = azurerm_resource_group.aks-rg.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = var.tags
}

resource "random_id" "acr_suffix" {
  byte_length = 4
}

resource "azurerm_role_assignment" "aks-acrpull-assign" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks-cluster.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

resource "azurerm_monitor_diagnostic_setting" "acr-log" {
  name                       = "ToLogAnalytics"
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aks-ws.id

  log {
    category = "ContainerRegistryRepositoryEvents"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "ContainerRegistryLoginEvents"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }
}
