resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "pedro-test-terraform-${var.environment}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_sse" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.environment == "prod" ? "aws:kms" : "AES256"
      kms_master_key_id = var.environment == "prod" ? module.pedro_key[0].key_id : null
    }
  }
}

module "enrique_key" {
  source = "terraform-aws-modules/kms/aws"

  count = var.environment == "prod" ? 1 : 0
  description = "enrique KMS key - (${var.environment})"
  key_usage   = "ENCRYPT_DECRYPT"

  key_administrators = ["arn:aws:iam::412381773585:root"]
  key_users          = ["arn:aws:iam::412381773585:root"]

  aliases = ["enrique-key-${var.environment}"]
}

resource "aws_s3_object" "archivos" {
  for_each = var.archivos

  bucket  = aws_s3_bucket.bucket.id
  key     = each.key
  content = each.value
}