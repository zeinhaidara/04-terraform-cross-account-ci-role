resource "aws_iam_role" "this" {
  name                 = var.role_name
  max_session_duration = 3600
  tags                 = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { AWS = var.ci_role_arn }
      Condition = {
        StringEquals = { "sts:ExternalId" = var.external_id }
      }
    }]
  })
}

# IAM rejects a statement with no resources, so skip the policy until some are given.
resource "aws_iam_role_policy" "this" {
  count = length(var.resource_arns) > 0 ? 1 : 0

  name = "allowed-actions"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = var.allowed_actions
      Resource = var.resource_arns
    }]
  })
}
