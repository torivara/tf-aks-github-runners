# terraform {
#   # Remember to authenticate with service principal (or similar commands for PowerShell)
#   # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret
#   # export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
#   # export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
#   # export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
#   # export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
#   backend "azurerm" {
#     resource_group_name  = "<backend-resource-group-name>"
#     storage_account_name = "<backend-storage-account-name>"
#     container_name       = "<backend-container-name>"
#     key                  = "terraformstate"
#   }
# }
