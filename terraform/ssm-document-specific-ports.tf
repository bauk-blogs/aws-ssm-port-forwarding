# Create the new whitelisted forward SSM Document, that is a copy of AWS-StartPortForwardingSession but with restricted ports
resource "aws_ssm_document" "forward_port" {
  for_each      = local.ssm_ports # You can generate one of these documents for each port
  name          = "ForwardPort${each.key}"
  document_type = "Session"

  content = jsonencode({
    schemaVersion = "1.0",
    description = "Document to start port forwarding session over Session Manager to port ${each.key}",
    sessionType = "Port",
    parameters = {
      localPortNumber = {
        type = "String",
        description = "(Optional) Port number on local machine to forward traffic to. An open port is chosen at run-time if not provided",
        allowedPattern = "^([0-9]|[1-9][0-9]{1,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$",
        default = "0"
      }
    },
    properties = {
      portNumber = each.key,
      type = "LocalPortForwarding",
      localPortNumber = "{{ localPortNumber }}"
    }
  })
}
