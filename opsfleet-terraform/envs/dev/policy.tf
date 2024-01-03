#### ESB IRSA ####


#### S3 Read ####

# Define an IAM policy that allows read, write, and decrypt permissions for an S3 bucket
resource "aws_iam_policy" "s3_read_write_decrypt" {
  name        = "S3ReadWriteDecryptPolicy"
  description = "Policy for reading, writing, and decrypting S3 objects"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:Get*"
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

# Define an IAM role that assumes the S3 read, write, and decrypt policy
resource "aws_iam_role" "gitlab_s3_read_write_decrypt" {
  name = "S3ReadWriteDecryptRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
        Action = "sts:AssumeRole",
      },
    ],
  })
}

resource "aws_iam_policy_attachment" "gitlab_s3_read_write_decrypt" {
  name = "S3ReadWriteDecrypt"
  policy_arn = aws_iam_policy.s3_read_write_decrypt.arn
  roles      = [aws_iam_role.gitlab_s3_read_write_decrypt.name]
}