variable "cluster_name" {
  type    = string
  default = "foo"
}

variable "oidc_provider_arn" {
  type = string
}

variable "namespaces" {
  type        = list(string)
  default     = []
  description = "Namespaces to create in the cluster"
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account Number"
}

variable "role_for_sa" {
  type        = string
  description = "the role to asosiate with the service account" 
}