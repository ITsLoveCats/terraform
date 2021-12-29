# AIntroducing AWS Client VPN to Securely Access AWS and On-Premises Resources
# https://aws.amazon.com/blogs/networking-and-content-delivery/introducing-aws-client-vpn-to-securely-access-aws-and-on-premises-resources/
# AD Authentication

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

variable "region" {
  default = "us-west-2"

}

# Configure the AWS Provider
# ==========================
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_cloud9_environment_ec2" "example" {
  instance_type = "t2.micro"
  name          = "example-env"
  subnet_id     = aws_subnet.subnet[0].id
}

# Networking ( VPC, Subnet, RouteTable, Gateway )
# ===============================================
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = var.tag
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = var.tag
}

resource "aws_subnet" "subnet" {
  count                   = length(var.subnet_cidr_block)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.subnet_cidr_block, count.index)
  availability_zone       = element(var.subnet_az, count.index)
  map_public_ip_on_launch = true

  depends_on = [aws_internet_gateway.igw]

  tags = var.tag
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = var.tag
}

resource "aws_route_table_association" "route_table" {
  count          = length(var.subnet_cidr_block)
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.route_table.id
}

# # Endof Networking

output "cloud9_url" {
  value = "https://${var.region}.console.aws.amazon.com/cloud9/ide/${aws_cloud9_environment_ec2.example.id}"
}

# # # Create EC2 Instance 
# # # ===================

# data "aws_ami" "amazonlinux" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["801119661308"] # Canonical
# }

# resource "aws_network_interface" "amazonlinux_nic" {
#   subnet_id       = aws_subnet.subnet[0].id
#   security_groups = ["${aws_security_group.SSH-sg.id}"]

#   tags = var.tag
# }

# resource "aws_instance" "ec2" {
#   ami           = data.aws_ami.amazonlinux.id
#   instance_type = "t2.micro"

#   network_interface {
#     network_interface_id = aws_network_interface.amazonlinux_nic.id
#     device_index         = 0
#   }

#   tags = var.tag

#   key_name = aws_key_pair.generated_key.key_name

# }

# resource "aws_security_group" "SSH-sg" {
#   name        = "SSH AllLocal Security Group"
#   description = "SSH AllLocal Security Group"
#   vpc_id      = aws_vpc.vpc.id

#   ingress {
#     description = "Remote Desktop"
#     cidr_blocks = [
#       "0.0.0.0/0"
#     ]
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"
#   }

#   ingress {
#     description = "All local VPC traffic"
#     cidr_blocks = [
#       var.vpc_cidr_block
#     ]
#     from_port = 0
#     to_port   = 0
#     protocol  = "-1"
#   }


#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = var.tag
# }

# # Endof Create EC2 Instance 

# # create ssh key for Instance Access
# # ==================================

# resource "tls_private_key" "for_aws_keypair" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "generated_key" {
#   key_name   = "iamkey"
#   public_key = tls_private_key.for_aws_keypair.public_key_openssh
# }

# # Endof create ssh key for Instance Access

# # output
# # ===================== #

# output "public_ip" {
#   value = aws_instance.ec2.public_ip
# }

# output "ssh_command" {
#   value = "ssh -i iamkey.pem ec2-user@${aws_instance.ec2.public_ip}"
# }

# resource "local_file" "pem_file" {
#   filename          = pathexpand("./iamkey.pem")
#   sensitive_content = tls_private_key.for_aws_keypair.private_key_pem
# }

# output "id" {
#   value = aws_iam_access_key.eks_project.id
# }

# output "secret" {
#   value     = aws_iam_access_key.eks_project.secret
#   sensitive = true
# }