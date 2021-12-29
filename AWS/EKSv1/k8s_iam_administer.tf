# Create IAM user for of Kubernetes Administer
# ============================================

resource "aws_iam_user" "eks_admin" {
  name = var.iam_name
  path = "/system/"

  tags = var.tag
}

resource "aws_iam_access_key" "eks_admin" {
  user = aws_iam_user.eks_admin.name
}

resource "aws_iam_policy_attachment" "eks-admin-attach" {
  name       = "eks-admin-attachment"
  users      = [var.iam_name]

  depends_on = [
    aws_iam_user.eks_admin
  ]
  policy_arn = data.aws_iam_policy.AdministratorAccess.arn
}

data "aws_iam_policy" "AdministratorAccess" {
  name = var.iam_policy_1
}

# Endof Create IAM user