variable "username" {
  default = "admin"
}

variable "password" {
}

variable "controller_ip" {
}

variable "ace_password" {
}

variable "aws_account_name" {
  default = "aws-account"
}

variable "aws_transit_instance_size" {
  default = "t2.micro"
}

variable "aws_transit1_region" {
  default = "eu-west-2"
}

variable "aws_transit1_name" {
  default = "aws-london-transit"
}

variable "aws_transit1_cidr" {
  default = "10.1.0.0/16"
}


variable "aws_transit2_region" {
  default = "ap-southeast-2"
}

variable "aws_transit2_name" {
  default = "aws-sydney-transit"
}

variable "aws_transit2_cidr" {
  default = "10.3.0.0/16"
}


variable "aws_spoke_instance_size" {
  default = "t2.micro"
}

variable "aws_spoke1_region" {
  default = "eu-west-2"
}

variable "aws_spoke1_name" {
  default = "aws-london-spoke"
}

variable "aws_spoke1_cidr" {
  default = "10.2.0.0/16"
}

variable "aws_spoke2_region" {
  default = "ap-southeast-2"
}

variable "aws_spoke2_name" {
  default = "aws-sydney-spoke"
}

variable "aws_spoke2_cidr" {
  default = "10.4.0.0/16"
}

variable "aws_test_instance_size" {
  default = "t2.micro"
}

variable "azure_account_name" {
  default = "azure-account"
}

variable "azure_subscription_id" {
}

variable "azure_client_id" {
}

variable "azure_client_secret" {
}

variable "azure_tenant_id" {
}

variable "gcloud_project_id" {
  default = "aviatrix-controller-account"
}

variable "gcp_transit1_region" {
  default = "asia-south1"
}

variable "gcp_transit1_name" {
  default = "gcp-mumbai-transit-gw"
}

variable "gcp_transit1_cidr" {
  default = "10.90.0.0/16"
}

variable "gcp_spoke1_region" {
  default = "asia-south1"
}

variable "gcp_spoke1_name" {
  default = "gcp-mumbai-spoke-gw"
}

variable "gcp_spoke1_cidr" {
  default = "10.50.0.0/16"
}

variable "gcp_account_name" {
  default = "gcp"
}

variable "ec2_key_name" {
  default = "ACE"
}

variable "azure_transit1_region" {
  default = "East US"
}

variable "azure_transit1_name" {
  default = "azure-virginia-transit"
}

variable "azure_transit1_cidr" {
  default = "10.70.0.0/16"
}

variable "azure_spoke_instance_size" {
  default = "Standard_B1ms"
}

variable "azure_spoke1_region" {
  default = "East US"
}

variable "azure_spoke1_name" {
  default = "azure-virginia-spoke"
}

variable "azure_spoke1_cidr" {
  default = "10.80.0.0/16"
}

variable "azure_test_instance_size" {
  default = "Standard_B1ms"
}

variable "ace_ec2_key_name" {
  default = "ACE"
}

variable "ha_enabled" {
  type    = bool
  default = false
}