access_key = "AKIAVP3ULLUBBZQXU3FI"
secret_key = "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"

vpc_cidr_block      = "172.31.0.0/16"
subnet_1_cidr_block = "172.31.0.0/24"
subnet_2_cidr_block = "172.31.1.0/24"

client_cidr_block = "10.0.0.0/16"
vpn_auth_type     = "directory-service-authentication"


aws_directory_service = {
  name     = "corp.notexample.com"
  password = "SuperSecretPassw0rd"
  edition  = "Standard"
  type     = "MicrosoftAD"
}

assume_role_policy = "sts:AssumeRole"
identifier         = "ec2.amazonaws.com"
iam_role           = "EC2DomainJoin"
iam_policy_1       = "AmazonSSMManagedInstanceCore"
iam_policy_2       = "AmazonSSMDirectoryServiceAccess"