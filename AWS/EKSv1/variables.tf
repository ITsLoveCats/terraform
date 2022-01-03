variable "region" {
}

variable "access_key" {
}

variable "secret_key" {
}

variable "vpc_name" {
}

variable "cloud9_iam" {
  type        = string
  description = "(optional) describe your variable"
}

variable "iam_name" {

}

variable "vpc_cidr_block" {
  type        = string
  description = "(optional) describe your variable"
}

variable "azs" {
}
variable "private_subnets" {
}

variable "public_subnets" {
}

variable "eks_cluster_name" {}
variable "eks_nodegroup_name" {}

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

variable "tag" {
  type        = map(string)
  description = "Metadata key/value pairs to make available from within the instance"
  default = {
    Name      = "AWSClientVPN",
    createdby = "terraform",
    env       = "Tutorial"
  }
}

variable "IAMRole_eks_admin" {}