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
