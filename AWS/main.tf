/*
    Use Terraform or Ansible or CloudFormation to automate the following tasks against any cloud provider platform, e.g. AWS, GCP, Aliyun.
*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

variable "awsid" {
  default = "AKIAY6LEO75WRZ7FVWH4"
}
variable "awskey" {
  default = "dube2993VFhR7oE8D1XK7NqM8nHLDBaNJz5CJkmd"
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = var.awsid
  secret_key = var.awskey
}

/*
    Provision a new VPC and any networking related configurations.
*/

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "tf-example"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "172.16.10.0/24"
  map_public_ip_on_launch = true

  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "tf-example"
  }
}

# Create a Route Table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "example"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.example.id
}

resource "aws_network_interface" "example" {
  subnet_id       = aws_subnet.my_subnet.id
  private_ips     = ["172.16.10.100"]
  security_groups = ["${aws_security_group.ingress-all.id}"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_security_group" "ingress-all" {
  name   = "allow-all-sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/*
    In this environment provision a virtual machine instance, with an OS of your choice.
*/

# Create an instance

data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  owners = ["amazon"]
}

resource "aws_instance" "example" {
  ami           = "ami-00aa7679554f67b63"
  instance_type = "t2.micro"

  get_password_data = true

  network_interface {
    network_interface_id = aws_network_interface.example.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  key_name = aws_key_pair.generated_key.key_name

  user_data = <<EOF
<powershell>
New-Item -Path c:\ -Name "testfile1.txt" -ItemType "file" -Value "This is a text string."

Invoke-Sqlcmd -Query "ALTER LOGIN sa ENABLE;" -ServerInstance "localhost" 

Invoke-sqlcmd -ServerInstance localhost -Query "ALTER LOGIN sa WITH PASSWORD ='P@ssw0rd'" 

Invoke-sqlcmd -ServerInstance localhost -Query `
"
USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', 
N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2
GO
" 

Restart-Service MSSQLSERVER

</powershell>
EOF

  tags = {
    Name = "HelloWorld"
  }
}

/*
    Generate ssh key
*/

# create ssh key
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "iamkey"
  public_key = tls_private_key.example.public_key_openssh
}


/* 
    Output
*/


output "public_ip" {
  value = aws_instance.example.public_ip
}

output "public_dns" {
  value = "ssh -i 'iamkey.pem' ec2-user@${aws_instance.example.public_dns}"
}

resource "local_file" "pem_file" {
  filename          = pathexpand("./iamkey.pem")
  sensitive_content = tls_private_key.example.private_key_pem
}

output "template_file" {
  value     = rsadecrypt(resource.aws_instance.example.password_data, resource.tls_private_key.example.private_key_pem)
  sensitive = true
}
