variable "tenant_id" {
  type = string
}

variable "vnet_name" {
  type    = string
  default = "aks-vnet"
}

variable "vnet_rg_name" {
  type    = string
  default = "aks-vnet"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "aks_subnet_name" {
  type    = string
  default = "aks"
}

variable "aks_subnet_prefix" {
  type    = list(string)
  default = ["10.0.0.0/17"]
}

variable "aks_rg_name" {
  type    = string
  default = "aks"
}

variable "aks_name" {
  type    = string
  default = "gh-runners"
}

variable "kubernetes_version" {
  type    = string
  default = "1.21.2"
}

variable "location" {
  type    = string
  default = "norwayeast"
}

variable "aks_agent_count" {
  type    = number
  default = 1
}

variable "prefix" {
  type    = string
  default = "tia"
}

variable "tags" {
  type = map(string)
  default = {
    "environment" = "Test"
    "costcenter"  = "Project 1234"
    "contact"     = "test@test.com"
  }
}

variable "service_cidr" {
  description = "kubernetes internal service cidr range"
  default     = "172.16.0.0/24"
}

variable "dns_service_ip" {
  description = "kubernetes dns service ip"
  default     = "172.16.0.10"
}

variable "docker_bridge_cidr" {
  description = "kubernetes docker bridge cidr"
  default     = "172.16.1.1/24"
}

variable "network_plugin" {
  default = "azure"
}

variable "key_vault_name" {
  type    = string
  default = "akskeyvault"
}

variable "acr_name" {
  type    = string
  default = "aksacr"
}
