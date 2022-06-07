##################################################################
# Data source to get AMI details
##################################################################
data "aws_ami" "ubuntu" {
  provider    = aws.london
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_ami" "ubuntu2" {
  provider    = aws.sydney
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_ami" "amazon_linux" {
  provider    = aws.london
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }
  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

data "aws_ami" "amazon_linux_west2" {
  provider    = aws.sydeny
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }
  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

data "template_file" "bu1_frontend_user_data" {
  template = file("${path.module}/aws-vm-config/aws_bootstrap.sh")
  vars = {
    name     = "BU1-Frontend"
    password = var.ace_password
  }
}

data "template_file" "bu2_mobile_app_user_data" {
  template = file("${path.module}/aws-vm-config/aws_bootstrap.sh")
  vars = {
    name     = "BU2-Mobile-App"
    password = var.ace_password
  }
}

module "security_group_1" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "~> 3.0"
  name                = "security_group_spoke1"
  description         = "Security group for example usage with EC2 instance"
  vpc_id              = module.aws_spoke_1.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "ssh-tcp", "all-icmp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8888
      to_port     = 8888
      protocol    = "tcp"
      description = "ethr tool"
      cidr_blocks = "${data.aws_network_interface.aws-spoke2-ubu-ni.private_ip}/32"
    },
    {
      from_port   = 5000
      to_port     = 5020
      protocol    = "tcp"
      description = "ntttcp tool"
      cidr_blocks = "${data.aws_network_interface.aws-spoke2-ubu-ni.private_ip}/32"
    },
  ]
  egress_rules = ["all-all"]
  providers = {
    aws = aws.london
  }
}

module "security_group_2" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "~> 3.0"
  name                = "security_group_spoke2"
  description         = "Security group for example usage with EC2 instance"
  vpc_id              = module.aws_spoke_2.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
  providers = {
    aws = aws.london
  }
}

module "aws_spoke_ubu_1" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "2.21.0"
  instance_type               = var.aws_test_instance_size
  name                        = "${var.aws_spoke1_name}-bu1-frontend"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = var.ec2_key_name
  subnet_id                   = module.aws_spoke_1.vpc.public_subnets[0].subnet_id
  vpc_security_group_ids      = [module.security_group_1.this_security_group_id]
  associate_public_ip_address = true
  user_data_base64            = base64encode(data.template_file.bu1_frontend_user_data.rendered)
  providers = {
    aws = aws.london
  }
  tags = {
    name        = "${var.aws_spoke1_name}-bu1-frontend"
    terraform   = "true"
    environment = "bu1"
  }
}

data "aws_network_interface" "aws-spoke1-ubu-ni" {
  provider = aws.london
  id       = module.aws_spoke_ubu_1.primary_network_interface_id[0]
}

module "aws_spoke_ubu_2" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "2.21.0"
  instance_type               = var.aws_test_instance_size
  name                        = "${var.aws_spoke2_name}-bu2-mobile-app"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = var.ec2_key_name
  subnet_id                   = module.aws_spoke_2.vpc.public_subnets[0].subnet_id
  vpc_security_group_ids      = [module.security_group_2.this_security_group_id]
  associate_public_ip_address = true
  user_data_base64            = base64encode(data.template_file.bu2_mobile_app_user_data.rendered)
  providers = {
    aws = aws.london
  }
  tags = {
    name        = "${var.aws_spoke2_name}-bu2-mobile-app"
    terraform   = "true"
    environment = "bu2"
  }
}

data "aws_network_interface" "aws-spoke2-ubu-ni" {
  provider = aws.london
  id       = module.aws_spoke_ubu_2.primary_network_interface_id[0]
}