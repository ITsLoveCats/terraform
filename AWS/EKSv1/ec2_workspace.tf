variable "vm_name" {
  default = "eks-workspace"
}

variable "attach_IAM_Role" {
  default = "IAMRole_eks_admin"
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

resource "aws_security_group" "ingress_ssh" {
  name   = "allow-ssh"
  vpc_id = module.vpc.vpc_id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.ingress_ssh.id
  network_interface_id = aws_network_interface.pri_nic.id
}

resource "aws_instance" "eks_workspace" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  iam_instance_profile = var.IAMRole_eks_admin

  network_interface {
    network_interface_id = aws_network_interface.pri_nic.id
    device_index         = 0
  }

  tags = {
    Name = var.vm_name
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  key_name = aws_key_pair.generated_key.key_name

  user_data = <<EOF
#!/bin/bash

mkdir -p /root/.aws

echo "[default]" >> /root/.aws/credentials
echo "aws_access_key_id=${var.access_key}" >> /root/.aws/credentials
echo "aws_secret_access_key=${var.secret_key}" >> /root/.aws/credentials

echo "[default]" >> /root/.aws/config
echo "region=${var.region}" >> /root/.aws/config
echo "output=yaml" >> /root/.aws/config

# installing kubectl
curl --silent --location -o /usr/local/bin/kubectl \
https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl

chmod +x /usr/local/bin/kubectl

kubectl completion bash >>  ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion

# installing aws cli
apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# installing eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/eksctl /usr/local/bin

eksctl completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
EOF
}

resource "aws_network_interface" "pri_nic" {
  subnet_id = module.vpc.public_subnets[0]

  tags = {
    Name = "${var.vm_name}_pri_nic"
  }
}

# create ssh key for Instance Access
# ==================================

resource "tls_private_key" "for_aws_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.vm_name}_iamkey.pem"
  public_key = tls_private_key.for_aws_keypair.public_key_openssh
}

# Endof create ssh key for Instance Access

output "public_dns" {
  value = "ssh -i ${var.vm_name}_iamkey.pem ubuntu@${aws_instance.eks_workspace.public_ip}"
}

resource "local_file" "pem_file" {
  filename          = pathexpand("./${var.vm_name}_iamkey.pem")
  sensitive_content = tls_private_key.for_aws_keypair.private_key_pem
}