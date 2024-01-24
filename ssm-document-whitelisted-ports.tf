locals {
  whitelisted_ports = [
    80,
    443,
    3000,
    8080,
    8443
  ]
}
# Create the new whitelisted forward SSM Document, that is a copy of AWS-StartPortForwardingSession but with restricted ports
resource "aws_ssm_document" "forward_whitelisted_ports" {
  name          = "ForwardWhitelistedPorts"
  document_type = "Session"

  content = jsonencode({
    schemaVersion = "1.0",
    description = "Document to start port forwarding session over Session Manager for a set of whitelisted ports",
    sessionType = "Port",
    parameters = {
      portNumber = {
        type = "String",
        description = "(Optional) Port number to connect to on the instance",
        allowedPattern = "^(${join("|", local.whitelisted_ports)})$",
        default = "443"
      },
      localPortNumber = {
        type = "String",
        description = "(Optional) Port number on local machine to forward traffic to. An open port is chosen at run-time if not provided",
        allowedPattern = "^([0-9]|[1-9][0-9]{1,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$",
        default = "0"
      }
    },
    properties = {
      portNumber = "{{ portNumber }}",
      type = "LocalPortForwarding",
      localPortNumber = "{{ localPortNumber }}"
    }
  })
}
