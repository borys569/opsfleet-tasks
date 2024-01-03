variable "bucket_name" {
  #"com.loopglobal.gov.www"
  type = string
}

variable "string_to_search" {
  default     = []
  description = "string to replace in bucket name to form the name for the west bucket"
}

variable "string_to_insert" {
  default = []
}

variable "attach_cloudfront_decrypt_policy" {
  description = "Controles if the module adds the policy to allow CF to use the key to decrypt files"
  default     = false
}

variable "aws_account_id" {
  description = "AWS account ID"
  default     = ""
}

variable "versioning" {
  description = "Enabled, Suspended, or Disabled"
  default     = "Disabled"
}

variable "tags" {
  default = ""
}

variable "force_destroy" {
  default     = false
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#force_destroy"
}