resource "aws_iam_instance_profile" "cloud9" {
  name = var.cloud9_iam
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = var.cloud9_iam
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "AdministratorAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.role.name
}
