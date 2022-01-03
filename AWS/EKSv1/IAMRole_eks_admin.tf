resource "aws_iam_instance_profile" "eks_admin_iam_role" {
  name = var.IAMRole_eks_admin
  role = aws_iam_role.eks_admin_iam_role.name
  depends_on = [
    aws_iam_role_policy_attachment.AdministratorAccess_a
  ]
}

resource "aws_iam_role" "eks_admin_iam_role" {
  name = var.IAMRole_eks_admin
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy_a.json
}

data "aws_iam_policy_document" "instance-assume-role-policy_a" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "AdministratorAccess_a" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.eks_admin_iam_role.name
}