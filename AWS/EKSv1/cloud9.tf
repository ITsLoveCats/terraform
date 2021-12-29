# Cloud 9
# =======

resource "aws_cloud9_environment_ec2" "cloud9" {
  instance_type = "t3.micro"
  name          = "cloud9-eks"
  subnet_id     = module.vpc.public_subnets[0]
}


data "aws_instance" "cloud9_instance" {
  filter {
    name = "tag:aws:cloud9:environment"
    values = [
    aws_cloud9_environment_ec2.cloud9.id]
  }
}

output "cloud9_url" {
  value = "https://${var.region}.console.aws.amazon.com/cloud9/ide/${aws_cloud9_environment_ec2.cloud9.id}"
}
