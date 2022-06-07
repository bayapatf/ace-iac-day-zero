provider "aviatrix" {
  controller_ip = var.controller_ip
  username      = var.username
  password      = var.password
}

provider "aws" {
  alias  = "ohio"
  region = var.aws_spoke1_region
}

provider "azurerm" {
  features {}
  skip_provider_registration = "true"
  subscription_id            = var.azure_subscription_id
  client_id                  = var.azure_client_id
  client_secret              = var.azure_client_secret
  tenant_id                  = var.azure_tenant_id
}

provider "gcloud" {
  project = "aviatrix-controller-account"
}

/*
provider "gcp" {
   gcloud_project_id = var.gcloud_project_id
   #gcloud_project_credentials_filepath = "/home/bayapa_mulluri/github/ace-iac-day-zero/aviatrix-controller-account-9f11275e470e.json"
}
*/