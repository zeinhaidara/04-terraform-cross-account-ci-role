mock_provider "aws" {}

variables {
  ci_role_arn = "arn:aws:iam::123456789012:role/ci"
  external_id = "example-external-id-1234"
}

run "trust_names_exact_ci_role" {
  command = plan

  assert {
    condition     = jsondecode(aws_iam_role.this.assume_role_policy).Statement[0].Principal.AWS == "arn:aws:iam::123456789012:role/ci"
    error_message = "Trust policy must name the CI role ARN, not the account root."
  }
}

run "trust_requires_external_id" {
  command = plan

  assert {
    condition     = jsondecode(aws_iam_role.this.assume_role_policy).Statement[0].Condition.StringEquals["sts:ExternalId"] == "example-external-id-1234"
    error_message = "Trust policy must require the external ID."
  }
}

run "wildcard_action_rejected" {
  command = plan

  variables {
    allowed_actions = ["s3:*"]
  }

  expect_failures = [var.allowed_actions]
}

run "session_is_one_hour" {
  command = plan

  assert {
    condition     = aws_iam_role.this.max_session_duration == 3600
    error_message = "Max session duration must be 3600 seconds."
  }
}
