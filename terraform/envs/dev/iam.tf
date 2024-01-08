
# IAM policy  for an S3 bucket

resource "aws_iam_policy" "s3_read_write_decrypt" {
  name        = "S3ReadWriteDecryptPolicy"
  description = "Policy for reading, writing, and decrypting S3 objects"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:*"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
        ],
        #Resource = "arn:aws:kms:us-east-1:your-account-id:key/your-kms-key-id", # Replace with your KMS key ARN
        Resource = "*"   
      },
    ],
  })
}

# Define an IAM role

resource "aws_iam_role" "s3_read_write_decrypt" {
  name = "S3ReadWriteDecryptRole"

  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Principal": {
              "Federated": "arn:aws:iam::${var.aws_account_id}:oidc-provider/${module.eks_dev.oidc_provider}"
          },
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Condition": {
              "StringEquals": {
                  "${module.eks_dev.oidc_provider}:sub": "system:serviceaccount:default:my-service-account",
                  "${module.eks_dev.oidc_provider}:aud": "sts.amazonaws.com"
              }
          }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_read_write_decrypt" {
  policy_arn = aws_iam_policy.s3_read_write_decrypt.arn
  role      = aws_iam_role.s3_read_write_decrypt.name
}