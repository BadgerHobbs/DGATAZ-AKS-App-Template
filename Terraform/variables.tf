
# Azure Subscription ID
variable "azure_subscription_id" {
    type = string
}

# Azure Tenant ID
variable "azure_tenant_id" {
    type = string
}

# Azure Client ID
variable "azure_client_id" {
    type = string
}

# Azure Client Secret
variable "azure_client_secret" {
    type = string
    sensitive = true
}

# ghcr.io username.
variable "ghcr_username" {
    type = string
}

# ghcr.io access token (password).
variable "ghcr_access_token" {
    type = string
    sensitive = true
}

# Docker image
variable "docker_image" {
    type = string
}
