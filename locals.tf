locals {
  # Each port in this list will generate an SSM document and IAM Policy allowing access to that specific port, to instances that have the specific  SSMPort<number> tag set to Enabled
  ssm_ports = toset([
    "80",
    "443"
  ])
}
