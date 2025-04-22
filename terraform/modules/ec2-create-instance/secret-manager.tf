resource "aws_secretsmanager_secret" "userdata" {
  count = var.secrets_file_path == "" ? 0 : 1
  #checkov:skip=CKV2_AWS_57:Ensure Secrets Manager secrets should have automatic rotation enabled
  name       = "instance_${var.instance_name}"
  kms_key_id = aws_kms_key.secret_key.id
}

resource "aws_secretsmanager_secret_version" "userdata" {
  count         = var.secrets_file_path == "" ? 0 : 1
  secret_id     = aws_secretsmanager_secret.userdata[0].id
  secret_string = file(var.secrets_file_path)
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "secret_key" {
  description             = "KMS key for Secrets Manager instance_${var.instance_name}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Allow the root user full access
      {
        Sid    = "EnableRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },

      # Allow Secrets Manager to use the key
      {
        Sid    = "AllowSecretsManagerUsage"
        Effect = "Allow"
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${var.aws_region}.amazonaws.com"
          }
        }
      }
    ]
  })
}
