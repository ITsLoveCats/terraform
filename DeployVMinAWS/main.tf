provider "aws" {
  region = "us-east-1"
  access_key = "AKIAWI45OM22IGUZHXKD"
  secret_key = "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"

}

resource "aws_instance" "vm" {
  ami = "ami-0be2609ba883822ec"
  subnet_id = "subnet-01cb3243db7329799"
  instance_type = "t3.micro"
  tags = {
    name = "my-first-tf-node"
  }
}