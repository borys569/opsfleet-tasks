variable "cluster_name" {
  type    = string
  default = "foo"
}

variable "oidc_provider_arn" {
  type = string
}

variable "namespaces" {
  type        = list(string)
  default     = ["default"]
  description = "Namespaces to create in the cluster"
}