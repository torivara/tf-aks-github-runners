# Self-Hosted GitHub-Runners in AKS

Repository with terraform code and kubernetes manifests for running self-hosted github-runners in Azure Kubernetes Service.

## Deployment

Follow [this](https://bit.ly/3tZBKSk) blog post for guidance on deployment.

## Repository Structure

* Repository Root
  * manifests
    * Contains manifest files for Kubernetes resource creation
  * scripts
    * Contains script for importing remote image to private Azure Container Registry
  * terraform
    * Contains all the terraform files necessary for deploying the entire solution

## Azure Setup

* Resource Group: prefix-aks-rg
  * Key Vault
  * Azure Container Registry
  * Azure Kubernetes Service
  * Log Analytics Workspace
  * Log Analytics Workspace Solution for Container Insights
* Resource Group: prefix-vnet-rg
  * Azure Virtual Network for AKS

## Other information

* Terraform handles the Role Based Access Control needed, also for pulling images from private ACR (AcrPull).
* Key Vault is deployed with RBAC enabled, and is not using Access Policies, but RBAC for assigning access to secrets.
* AKS is deployed with two node pools: one for critical system services and one for user services.
  * This is best practice to avoid exhausting resources for critical system services if wrongly configured deployments.
  * Critical addons only added to system pool, so only system services run there by default.
