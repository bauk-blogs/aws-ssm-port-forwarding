# Get your account ID to use in the policies later
data "aws_caller_identity" "current" {}

# Create an IAM role that will be used to initiate the SSM connection
# The assume role policy here should be updated if you need to customise who can assume this role
resource "aws_iam_role" "ssm_role" {
  name                = "SSMPipelineRole"
  managed_policy_arns = [
    aws_iam_policy.ssm_port["443"].arn,
    aws_iam_policy.ssm_whitelisted_ports.arn,
  ]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      },
    ]
  })
}


