resource "aws_iam_policy" "policy" {
  name        = "SessionManagerPermissions"
  path        = "/"
  description = "SessionManagerPermissions https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-create-iam-instance-profile.html"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:UpdateInstanceInformation",
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetEncryptionConfiguration"
            ],
            "Resource": "*"
        }
    ]
  })
}

resource "aws_iam_instance_profile" "MySessionManagerRole" {
  name = "MySessionManagerRole"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "MySessionManagerRole"
  description = "https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-create-iam-instance-profile.html"
  path = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

data "aws_iam_policy" "CloudWatchAgentServerPolicy" {
  name = "CloudWatchAgentServerPolicy"
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "attach-MySessionManagerRole-1" {
  role      = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.CloudWatchAgentServerPolicy.arn
}

resource "aws_iam_role_policy_attachment" "attach-MySessionManagerRole-2" {
  role      = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}