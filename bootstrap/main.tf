resource "aws_s3_bucket" "lambda_state" {

  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "lamda_state" {
  bucket = aws_s3_bucket.lambda_state.id
  versioning_configuration {
    status = "Enabled"
  }
  depends_on = [aws_s3_bucket.lambda_state]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lamda_state" {
  bucket = aws_s3_bucket.lambda_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
  depends_on = [aws_s3_bucket.lambda_state]
}

resource "aws_s3_bucket_object_lock_configuration" "lamda_state" {
  bucket = aws_s3_bucket.lambda_state.id
}

resource "aws_dynamodb_table" "lamda_state" {
  name           = "terraform-state"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags       = var.tags
  depends_on = [aws_s3_bucket.lambda_state]
}
# resource "aws_s3_bucket_public_access_block" "this" {
#   block_public_acls       = true
#   block_public_policy     = true
#   bucket                  = aws_s3_bucket.lambda_state.id
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
#   bucket = aws_s3_bucket.lambda_state.id
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# data "aws_iam_policy_document" "lambda_state" {
#   policy_id = "TrustedSourceIPs"
#   statement {
#     actions = ["s3:*"]
#     condition {
#       test     = "NotIpAddress"
#       variable = "aws:SourceIp"
#       values   = var.allowed_ips
#     }
#     effect = "Deny"
#     principals {
#       identifiers = ["*"]
#       type        = "*"
#     }
#     resources = [
#       "${aws_s3_bucket.lambda_state.arn}",
#       "${aws_s3_bucket.lambda_state.arn}/*"
#     ]
#     sid = "IPAllow"
#   }
# }

# resource "aws_s3_bucket_policy" "this" {
#   bucket = aws_s3_bucket.lambda_state.id
#   policy = data.aws_iam_policy_document.lamda_state.json
# }
