variable "role_name" {
  description = "Name of the IAM role created in the workload account."
  type        = string
  default     = "ci-cross-account"
}

variable "ci_role_arn" {
  description = "ARN of the CI role in the shared-services account that may assume this role."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:", var.ci_role_arn))
    error_message = "ci_role_arn must start with arn:aws:iam:: followed by a 12-digit account ID."
  }
}

variable "external_id" {
  description = "External ID the caller must pass when assuming the role."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.external_id) >= 16 && length(var.external_id) <= 64
    error_message = "external_id must be 16 to 64 characters."
  }
}

variable "allowed_actions" {
  description = "IAM actions the role may perform."
  type        = list(string)
  default     = ["s3:GetObject", "s3:ListBucket"]

  validation {
    condition     = alltrue([for a in var.allowed_actions : a != "*" && !endswith(a, ":*")])
    error_message = "allowed_actions must not contain \"*\" or any service-wide \":*\" action."
  }
}

variable "resource_arns" {
  description = "Resources the allowed actions apply to. No policy is created while empty."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags added to the role."
  type        = map(string)
  default     = {}
}
