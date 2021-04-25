resource "aws_s3_bucket" "codebuild_bucket" {
  bucket        = "${var.prefix}-pipeline"
  acl           = "private"
  force_destroy = true

  tags = var.tags

  lifecycle_rule {
    id      = "log"
    enabled = true

    tags = {
      "rule"      = "log"
      "autoclean" = "true"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA" # or "ONEZONE_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }
}
