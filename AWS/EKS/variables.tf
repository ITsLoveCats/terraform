variable "access_key" {
  type        = string
  description = "(optional) describe your variable"
}

variable "secret_key" {
  type        = string
  description = "(optional) describe your variable"
}

variable "iam_name" {

}

variable "vpc_cidr_block" {
  type        = string
  description = "(optional) describe your variable"
}

variable "subnet_cidr_block" {
  description = "(optional) describe your variable"
}

variable "subnet_az" {
  
}


variable "client_cidr_block" {
  type        = string
  description = "(optional) describe your variable"
}


variable "aws_directory_service" {
  type        = map(string)
  description = "(optional) describe your variable"
}

variable "assume_role_policy" {
  type        = string
  description = "(optional) describe your variable"
}

variable "iam_role" {
  type        = string
  description = "(optional) describe your variable"
}

variable "identifier" {
  type        = string
  description = "(optional) describe your variable"
}

variable "iam_policy_1" {
  type        = string
  description = "(optional) describe your variable"
}

variable "iam_policy_2" {
  type        = string
  description = "(optional) describe your variable"
}

variable "vpn_auth_type" {
  type        = string
  description = "(optional) describe your variable"
}

variable "tag" {
  type        = map(string)
  description = "Metadata key/value pairs to make available from within the instance"
  default = {
    Name      = "AWSClientVPN",
    createdby = "terraform",
    env       = "Tutorial"
  }
}
