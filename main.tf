//ACE-IAC Core Aviatrix Infrastructure

#Private Key creation
resource "tls_private_key" "avtx_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ace_key" {
  provider   = aws.ohio
  key_name   = var.ace_ec2_key_name
  public_key = tls_private_key.avtx_key.public_key_openssh
}

#Create an Aviatrix Azure Account
resource "aviatrix_account" "azure_account" {
  account_name        = var.azure_account_name
  cloud_type          = 8
  arm_subscription_id = var.azure_subscription_id
  arm_directory_id    = var.azure_tenant_id
  arm_application_id  = var.azure_client_id
  arm_application_key = var.azure_client_secret
}

/*
# Create an Aviatrix GCP Account
resource "aviatrix_account" "gcp_account" {
  account_name                        = "gcp"
  cloud_type                          = 4
  gcloud_project_id                   = "aviatrix-controller-account"
  gcloud_project_credentials_filepath = "/home/bayapa_mulluri/github/ace-iac-day-zero/aviatrix-controller-account-9f11275e470e.json"
}


resource "aviatrix_account" "account_1" {
    account_name = "aws-account"
    cloud_type = 1
    aws_account_number = "256271308280"
    aws_iam = true
    aws_role_app = "arn:aws:iam::256271308280:role/aviatrix-role-app"
    aws_role_ec2 = "arn:aws:iam::256271308280:role/aviatrix-role-ec2"
    aws_access_key = ""
    aws_secret_key = ""
}

resource "aviatrix_account" "account_2" {
    account_name = "azure-account"
    cloud_type = 8
    arm_subscription_id = "3c40bbc6-6ab7-4225-83e7-74c74289b3bd"
    arm_directory_id = ""
    arm_application_id = ""
    arm_application_key = ""
}

resource "aviatrix_account" "account_3" {
    account_name = "gcp"
    cloud_type = 4
    gcloud_project_id = "aviatrix-controller-account"
    gcloud_project_credentials_filepath = ""
}
*/

#AWS Transit Modules
module "aws_transit_1" {
  source              = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version             = "1.1.3"
  cloud               = "AWS"
  account             = var.aws_account_name
  region              = var.aws_transit1_region
  name                = var.aws_transit1_name
  cidr                = var.aws_transit1_cidr
  ha_gw               = var.ha_enabled
  instance_size       = var.aws_transit_instance_size
  enable_segmentation = false
}
module "aws_transit_2" {
  source              = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version             = "1.1.3"
  cloud               = "AWS"
  account             = var.aws_account_name
  region              = var.aws_transit2_region
  name                = var.aws_transit2_name
  cidr                = var.aws_transit2_cidr
  ha_gw               = var.ha_enabled
  instance_size       = var.aws_transit_instance_size
  enable_segmentation = false
}


#AWS Spoke Modules
module "aws_spoke_1" {
  source        = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version       = "1.1.2"
  cloud         = "AWS"
  account       = var.aws_account_name
  region        = var.aws_spoke1_region
  name          = var.aws_spoke1_name
  cidr          = var.aws_spoke1_cidr
  instance_size = var.aws_spoke_instance_size
  ha_gw         = var.ha_enabled
  transit_gw    = module.aws_transit_1.transit_gateway.gw_name
}

module "aws_spoke_2" {
  source        = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version       = "1.1.2"
  cloud         = "AWS"
  account       = var.aws_account_name
  region        = var.aws_spoke2_region
  name          = var.aws_spoke2_name
  cidr          = var.aws_spoke2_cidr
  instance_size = var.aws_spoke_instance_size
  ha_gw         = var.ha_enabled
  transit_gw    = module.aws_transit_2.transit_gateway.gw_name
}


module "azure_transit_1" {
  source        = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version       = "2.0.2"
  cloud         = "Azure"
  account       = aviatrix_account.azure_account.account_name
  region        = var.azure_transit1_region
  name          = var.azure_transit1_name
  cidr          = var.azure_transit1_cidr
  instance_size = var.azure_spoke_instance_size
  ha_gw         = var.ha_enabled
}

module "azure_spoke_1" {
  source        = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version       = "1.1.2"
  cloud         = "Azure"
  account       = aviatrix_account.azure_account.account_name
  region        = var.azure_spoke1_region
  name          = var.azure_spoke1_name
  cidr          = var.azure_spoke1_cidr
  instance_size = var.azure_spoke_instance_size
  ha_gw         = var.ha_enabled
  transit_gw    = module.azure_transit_1.transit_gateway.gw_name
}

# Create an Aviatrix Transit Gateway Peering
resource "aviatrix_transit_gateway_peering" "aws_transit_gateway_peering" {
  transit_gateway_name1 = module.aws_transit_1.transit_gateway.gw_name
  transit_gateway_name2 = module.aws_transit_2.transit_gateway.gw_name
}

resource "aviatrix_transit_gateway_peering" "aws_london_azure_virginia_transit_gateway_peering" {
  transit_gateway_name1 = module.aws_transit_1.transit_gateway.gw_name
  transit_gateway_name2 = module.azure_transit_1.transit_gateway.gw_name
}

resource "aviatrix_transit_gateway_peering" "aws_sydney_azure_virginia_transit_gateway_peering" {
  transit_gateway_name1 = module.aws_transit_2.transit_gateway.gw_name
  transit_gateway_name2 = module.azure_transit_1.transit_gateway.gw_name
}


module "gcp_transit_1" {
  source              = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version             = "1.1.3"
  cloud               = "GCP"
  account             = var.gcp_account_name
  region              = var.gcp_transit1_region
  name                = var.gcp_transit1_name
  cidr                = var.gcp_transit1_cidr
  enable_segmentation = false
  ha_gw               = var.ha_enabled
}


/*
module "gcp_transit_1" {
  source             = "terraform-aviatrix-modules/gcp-transit/aviatrix"
  version            = "2.0.1"
  account            = "GCP"
  cidr               = "10.10.0.0/16"
  region             = "us-east1"
  ha_gw              = false
}

module "azure_transit" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.0.2"
  cloud   = "azure"
  region  = "East US"
  cidr    = "10.1.0.0/23"
  account = aviatrix_account.azure_account.account_name
}

module "azure_spoke_2" {
  source          = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version         = "1.1.2"
  cloud           = "Azure"
  account         = aviatrix_account.azure_account.account_name
  region          = var.azure_spoke2_region
  name            = var.azure_spoke2_name
  cidr            = var.azure_spoke2_cidr
  instance_size   = var.azure_spoke_instance_size
  ha_gw           = var.ha_enabled
  security_domain = aviatrix_segmentation_security_domain.BU2.domain_name
  transit_gw      = module.aws_transit_1.transit_gateway.gw_name
}

#Multi-Cloud Segmentation
resource "aviatrix_segmentation_security_domain" "BU1" {
  domain_name = "BU1"
  depends_on = [
    module.aws_transit_1
  ]
}
resource "aviatrix_segmentation_security_domain" "BU2" {
  domain_name = "BU2"
  depends_on = [
    module.aws_transit_1
  ]
}

resource "aviatrix_segmentation_security_domain_connection_policy" "BU1_BU2" {
  domain_name_1 = aviatrix_segmentation_security_domain.BU1.domain_name
  domain_name_2 = aviatrix_segmentation_security_domain.BU2.domain_name
  depends_on    = [aviatrix_segmentation_security_domain.BU1, aviatrix_segmentation_security_domain.BU2]
}
*/