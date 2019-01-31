resource "aws_cloudfront_distribution" "tilegarden" {
  origin {
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1", "TLSv1"]
      origin_read_timeout    = 60
    }

    domain_name = "${var.tilegarden_api_gateway_domain_name}"
    origin_id   = "tilegardenOriginEastId"

    custom_header {
      name  = "Accept"
      value = "image/png"
    }
  }

  origin {
    custom_origin_config {
      http_port  = 80
      https_port = 443

      # S3 websites don't support TLS :/
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1", "TLSv1"]
    }

    domain_name = "${aws_s3_bucket.tile_cache.website_endpoint}"
    origin_id   = "tilegardenCacheOriginEastId"

    custom_header {
      name  = "Accept"
      value = "image/png"
    }
  }

  aliases         = ["tiles.${var.r53_public_hosted_zone}"]
  price_class     = "${var.cloudfront_price_class}"
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.project} (${var.environment})"

  # Tilegarden cache origin
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "tilegardenCacheOriginEastId"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = "300"               # Five minutes
    max_ttl                = "86400"             # One day
  }

  # Tilegarden lambda origin for generating new tiles
  cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "tilegardenOriginEastId"
    path_pattern     = "/latest/*"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = "300"               # Five minutes
    max_ttl                = "86400"             # One day
  }

  restrictions {
    "geo_restriction" {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.ssl_certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  tags {
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}
