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

# Configure the AWS Provider
# ==========================
provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}


# External NAT Gateway IPs
# ========================
resource "aws_eip" "nat" {
  count = 3

  vpc = true
}
# # Endof Provision External NAT Gateway


# Networking ( VPC, Subnet, RouteTable, Gateway )
# ===============================================
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = false

  reuse_nat_ips       = true 
  external_nat_ip_ids = "${aws_eip.nat.*.id}"                    

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
# # Endof Networking

# Security Group
# ==============
resource "aws_security_group" "bastion-sg" {
  name   = "bastion-security-group"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private-instance-sg" {
  name   = "private-instance-security-group"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
  }  

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# # Endof Security Group

# Get ami id 
############
data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Canonical
}

data "aws_ami" "ubuntu" {
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
# Endof Get ami id

# Create Bastion Instance 
# =======================

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "bastion-instance"

  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.bastion_key.id
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.bastion-sg.id}"]
  subnet_id              = "${module.vpc.public_subnets[0]}"

  associate_public_ip_address = true

  user_data =<<EOT
#!/bin/bash
echo '"${tls_private_key.instance_keypair.private_key_pem}"' >> /home/ec2-user/iamkey.pem
chmod 400 /home/ec2-user/iamkey.pem
chown ec2-user /home/ec2-user/iamkey.pem
chgrp ec2-user /home/ec2-user/iamkey.pem
EOT

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

output "bastion_ip" {
  value = module.ec2_instance.public_ip
}
# Endof Bastion Instance Instance

module "ec2_instance_a" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "instance-subnet-a"

  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.id
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.private-instance-sg.id}"]
  subnet_id              = "${module.vpc.public_subnets[0]}"
  associate_public_ip_address = false

  iam_instance_profile = "MySessionManagerRole"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
output "ec2_instance_a_ip" {
  value = module.ec2_instance_a.private_ip
} 

module "ec2_instance_b" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "instance-subnet-b"

  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.id
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.private-instance-sg.id}"]
  subnet_id              = "${module.vpc.public_subnets[1]}"
  associate_public_ip_address = false

  iam_instance_profile = "MySessionManagerRole"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
output "ec2_instance_b_ip" {
  value = module.ec2_instance_b.private_ip
} 

module "ec2_instance_c" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "instance-subnet-c"

  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.id
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.private-instance-sg.id}"]
  subnet_id              = "${module.vpc.public_subnets[2]}"
  associate_public_ip_address = false

  iam_instance_profile = "MySessionManagerRole"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
output "ec2_instance_c_ip" {
  value = module.ec2_instance_c.private_ip
} 

# # Create EC2 Instance 
# # ===================

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

# Endof Create EC2 Instance 

# create ssh key for Instance Access
# ==================================

resource "tls_private_key" "bastion_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "instance_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "iamkey"
  public_key = tls_private_key.instance_keypair.public_key_openssh
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion_key"
  public_key = tls_private_key.bastion_keypair.public_key_openssh
}

# Endof create ssh key for Instance Access

# output
# ===================== #

# output "public_ip" {
#   value = aws_instance.ec2.public_ip
# }

# output "ssh_command" {
#   value = "ssh -i iamkey.pem ec2-user@${aws_instance.ec2.public_ip}"
# }

resource "local_file" "pem_file_1" {
  filename          = pathexpand("./bastion_key.pem")
  sensitive_content = tls_private_key.bastion_keypair.private_key_pem
}

resource "local_file" "pem_file_2" {
  filename          = pathexpand("./iamkey.pem")
  sensitive_content = tls_private_key.instance_keypair.private_key_pem
}

# output "id" {
#   value = aws_iam_access_key.eks_project.id
# }

# output "secret" {
#   value     = aws_iam_access_key.eks_project.secret
#   sensitive = true
# }