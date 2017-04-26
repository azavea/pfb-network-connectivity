resource "aws_s3_bucket" "static" {
  bucket = "${lower("${var.environment}")}-pfb-static-${var.aws_region}"
  acl    = "private"

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET"]
    max_age_seconds = 3000
    allowed_headers = ["Authorization"]
  }

  tags {
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

resource "aws_s3_bucket" "storage" {
  bucket = "${lower("${var.environment}")}-pfb-storage-${var.aws_region}"
  acl    = "public-read"
  policy = "${data.aws_iam_policy_document.anonymous_read_storage_bucket_policy.json}"

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET", "HEAD"]
    max_age_seconds = 3000
    allowed_headers = ["Authorization"]
    expose_headers  = ["ETag"]
  }

  tags {
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}
