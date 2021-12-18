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

# Networking ( VPC, Subnet, RouteTable, Gateway )
# ===============================================
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = var.tag
}

resource "aws_vpc_dhcp_options" "vpc_dhcp_options" {
  domain_name         = var.aws_directory_service.name
  domain_name_servers = aws_directory_service_directory.vpn_auth.dns_ip_addresses

  tags = {
    Name = "AWS DS DHCP"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.vpc_dhcp_options.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = var.tag
}

resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_1_cidr_block
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  depends_on = [aws_internet_gateway.igw]

  tags = var.tag
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_2_cidr_block
  availability_zone       = "us-east-1b"
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

resource "aws_route_table_association" "subnet_1_route_table" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet_2_route_table" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.route_table.id
}

# Endof Networking


# Create Microsoft Active Directory (MicrosoftAD)
# ===============================================
resource "aws_directory_service_directory" "vpn_auth" {
  name     = var.aws_directory_service.name
  password = var.aws_directory_service.password
  edition  = var.aws_directory_service.edition
  type     = var.aws_directory_service.type

  vpc_settings {
    vpc_id     = aws_vpc.vpc.id
    subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  }

  tags = var.tag
}

# Endof Create Microsoft Active Directory (MicrosoftAD)


# Create IAM Role
# ===============
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = [var.assume_role_policy]

    principals {
      type        = "Service"
      identifiers = ["${var.identifier}"]
    }
  }
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  name = var.iam_policy_1
}

data "aws_iam_policy" "AmazonSSMDirectoryServiceAccess" {
  name = var.iam_policy_2
}

resource "aws_iam_role" "EC2DomainJoin" {
  name               = var.iam_role
  path               = "/terraform/awsclientvpn/"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.EC2DomainJoin.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

resource "aws_iam_role_policy_attachment" "AmazonSSMDirectoryServiceAccess" {
  role       = aws_iam_role.EC2DomainJoin.name
  policy_arn = data.aws_iam_policy.AmazonSSMDirectoryServiceAccess.arn
}

# Endof Create IAM Role

# Create EC2 Instance to Join the directory
# =========================================

data "aws_ami" "WindowsServer" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["801119661308"] # Canonical
}

resource "aws_network_interface" "WindowsServer_nic" {
  subnet_id       = aws_subnet.subnet_1.id
  security_groups = ["${aws_security_group.AWS-DS-sg.id}"]

  tags = var.tag
}

resource "aws_instance" "WindowsServer" {
  ami           = data.aws_ami.WindowsServer.id
  instance_type = "t2.micro"

  get_password_data = true

  depends_on = [
    aws_directory_service_directory.vpn_auth
  ]

  network_interface {
    network_interface_id = aws_network_interface.WindowsServer_nic.id
    device_index         = 0
  }

  tags = var.tag

  key_name = aws_key_pair.generated_key.key_name

  user_data = <<EOF
<powershell>
Add-Computer -DomainName 'corp.notexample.com"' `
-NewName 'ADDS' `
-Credential (New-Object -TypeName PSCredential -ArgumentList "admin",(ConvertTo-SecureString -String 'SuperSecretPassw0rd' `
-AsPlainText -Force)[0]) -Restart
</powershell>
EOF

}

resource "aws_security_group" "AWS-DS-sg" {
  name        = "AWS DS Security Group"
  description = "AWS DS Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Remote Desktop"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"
  }

  ingress {
    description = "All local VPC traffic"
    cidr_blocks = [
      var.vpc_cidr_block
    ]
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tag
}
# Endof Create EC2 Instance to Join the directory

# Create AWS Client VPN
# =====================

resource "aws_ec2_client_vpn_endpoint" "aws_client_vpn" {
  description            = "terraform-clientvpn"
  client_cidr_block      = var.client_cidr_block
  server_certificate_arn = aws_acm_certificate.vpn_cert.id
  dns_servers            = ["1.1.1.1", "8.8.8.8."]


  authentication_options {
    type                = var.vpn_auth_type
    active_directory_id = aws_directory_service_directory.vpn_auth.id
  }

  connection_log_options {
    enabled              = true
    cloudwatch_log_group = aws_cloudwatch_log_group.vpn_lg.name
  }
}

resource "aws_ec2_client_vpn_authorization_rule" "aws_client_vpn" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.aws_client_vpn.id
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_network_association" "aws_client_vpn" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.aws_client_vpn.id
  subnet_id              = aws_subnet.subnet_1.id
  security_groups        = ["${aws_security_group.AWS-DS-sg.id}"]
}

resource "aws_ec2_client_vpn_route" "defaultRoute" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.aws_client_vpn.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = aws_ec2_client_vpn_network_association.aws_client_vpn.subnet_id
}

resource "tls_private_key" "vpn" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "vpn" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.vpn.private_key_pem

  subject {
    common_name  = "vpn.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "vpn_cert" {
  private_key      = tls_private_key.vpn.private_key_pem
  certificate_body = tls_self_signed_cert.vpn.cert_pem
}

resource "aws_cloudwatch_log_group" "vpn_lg" {
  name = "AWSClientVPN"

  tags = var.tag
}

# Endof AWS Client VPN

# create ssh key for Instance Access
# ==================================

resource "tls_private_key" "for_aws_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "iamkey"
  public_key = tls_private_key.for_aws_keypair.public_key_openssh
}

# Endof create ssh key for Instance Access

# output
# ===================== #

output "public_ip" {
  value = aws_instance.WindowsServer.public_ip
}


resource "local_file" "pem_file" {
  filename          = pathexpand("./iamkey.pem")
  sensitive_content = tls_private_key.for_aws_keypair.private_key_pem
}

output "template_file" {
  value     = rsadecrypt(resource.aws_instance.WindowsServer.password_data, resource.tls_private_key.example.private_key_pem)
  sensitive = true
}
