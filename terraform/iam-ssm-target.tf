# You can attach this policy to the instance that you are trying to access if it does not already have the required permissions to connect to SSM
resource "aws_iam_policy" "ssm_target" {
  name = "SSMTarget"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Code for connecting this role
#resource "aws_iam_role_policy_attachment" "ssm_target" {
#  role       = aws_iam_role.ecs_or_ec2_instance_role.name # Role attached to the instance you want to connect to
#  policy_arn = aws_iam_policy.ssm_target.arn
#}
