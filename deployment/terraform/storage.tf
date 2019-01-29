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

  lifecycle_rule {
    id = "osm_extracts"
    enabled = true
    prefix = "/osm-data-cache"
    expiration {
      days = 7
    }
  }
}

resource "aws_s3_bucket" "tile_cache" {
  bucket = "${lower(var.environment)}-pfb-tile-cache-${var.aws_region}"
  acl    = "public-read"
  policy = "${data.aws_iam_policy_document.anonymous_read_tile_cache_bucket_policy.json}"

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = "3000"
  }

  website {
    index_document = "index.html"
    routing_rules  = <<EOF
[{
    "Condition": {
        "HttpErrorCodeReturnedEquals": "404"
    },
    "Redirect": {
        "HostName": "tiles.${var.r53_public_hosted_zone}",
        "HttpRedirectCode": "302",
        "Protocol": "https",
        "ReplaceKeyPrefixWith": "latest/"
    }
}]
EOF
  }

  tags {
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}
