#-----------------------------------------------------------
# Common
#-----------------------------------------------------------
variable "name" {
  type        = string
  description = "(Required) This name will be used in all resources."
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags applied to all resources."
  default     = {}
}

#-----------------------------------------------------------
# AWS
#-----------------------------------------------------------
variable "iam_policy_statements" {
  type = list(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
  description = "(Optional) List of policy statements for the policy attached to the IAM role."
  default     = []
}

variable "iam_policy_description" {
  type        = string
  description = "(Optional) Description for your IAM policy."
  default     = ""
}

variable "iam_role_description" {
  type        = string
  description = "(Optional) describe your variable"
  default     = ""
}

variable "oidc_provider" {
  type        = string
  description = "(Required) An existing IAM OpenID Connect (OIDC) provider from your EKS cluster."
}

#-----------------------------------------------------------
# Kubernetes
#-----------------------------------------------------------
variable "k8s_namespace" {
  type        = string
  description = "(Optional) A Kubernetes namespace where the service account will be created."
  default     = "default"
}
