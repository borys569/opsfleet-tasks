# creates bucket with encryption

locals {
  # replica_bucket_name = replace(var.bucket_name, var.string_to_search, var.string_to_insert)
  source_bucket_arn = "arn:aws:s3:::${var.bucket_name}"
  # replica_bucket_arn  = "arn:aws:s3:::${local.replica_bucket_name}"
  kms_policy             = var.attach_cloudfront_decrypt_policy ? local.kms_policy_doc_cloudfront : local.kms_policy_doc_regular
  kms_policy_doc_regular = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.aws_account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        }
    ]
}
POLICY

  kms_policy_doc_cloudfront = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.aws_account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "AllowCloudFrontServicePrincipalSSE-KMS",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.aws_account_id}:root",
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:GenerateDataKey*"
            ],
            "Resource": "*"
        }
    ]
}
POLICY

}

# main bucket

resource "aws_s3_bucket" "this" {
  #provider = aws.east

  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning
  }
}

# resource "aws_s3_bucket_acl" "this" {
#   bucket = aws_s3_bucket.this.id
#   acl    = "private"
# }

resource "aws_s3_bucket_public_access_block" "this" {
  #provider = aws.east
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# encrypt

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  #provider = aws.east

  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      # kms_master_key_id = aws_kms_key.this.arn # use default key
    }
  }
}

# resource "aws_kms_key" "this" {
#   #provider = aws.east

#   description = var.bucket_name
#   policy = local.kms_policy
# }

# frinedly alias to identify the key
# resource "aws_kms_alias" "this" {
#   #provider = aws.east

#   name          = "alias/${replace(var.bucket_name, ".", "-")}"
#   target_key_id = aws_kms_key.this.key_id
# }