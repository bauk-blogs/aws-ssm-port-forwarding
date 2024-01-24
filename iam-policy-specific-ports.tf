# This policy allows the role to start SSM port forwarding sessions against port 443 on ECS tasks or EC2 instances that have the SSMPort443 tag set to Enabled
# If multiple ports are specified in local.ssm_ports, one policy will be created for each port
resource "aws_iam_policy" "ssm_port" {
  for_each = local.ssm_ports
  name = "SSMPortForward${each.key}Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # This describe/list block is just here so that we can find the instance or task we want to use
      {
        Action   = [
          "ecs:List*",
          "ecs:Describe*",
          "ec2:List*",
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      # This allows us to start the SSM sessions against both tasks and instances
      # It limits to only allowing access to boxes with the specified tag
      # You can remove one of these targets if not needed
      {
        Action   = [
          "ssm:StartSession",
        ]
        Effect   = "Allow"
        Resource = [
            "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:task/*",
            "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:instance/*",
        ]
        Condition = {
            StringLike = {
                "aws:resourceTag/SSMPort${each.key}" = [
                    "Enabled"
                ]
            }
        }
      },
      # This allows us to start sessions against the specific SSM Document
      {
        Action   = [
          "ssm:StartSession",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:ssm:*:*:document/ForwardPort${each.key}",
        ]
      },
      # This is optional, and ensures the role cannot use the default forwarding document
      # You can optionally remove all AWS documents (as seen in the second line)
      # However a better solution may be to ensure you have not allowed SSM anywhere else
      {
        Action   = [
          "ssm:StartSession",
        ]
        Effect   = "Deny"
        Resource = [
          "arn:aws:ssm:*:*:document/AWS-StartPortForwardingSession*",
          "arn:aws:ssm:*:*:document/AWS-*",
        ]
      },
      # This ensures the role can terminate and resume it's own SSM sessions
      {
        Action   = [
          "ssm:TerminateSession",
          "ssm:ResumeSession"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ssm:*:*:session/$${aws:userid}-*"
      },
    ]
  })
}
