resource "aws_s3_bucket" "multi-tier-vpc-html" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy_bucket

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_cloudfront_origin_access_control" "multi-tier-vpc-html" {
  name                              = "${var.project_name}-${var.environment}-oac"
  description                       = "OAC for private S3 static website bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "multi-tier-vpc-html" {
  enabled             = true
  comment             = "${var.project_name}-${var.environment}"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name              = aws_s3_bucket.multi-tier-vpc-html.bucket_regional_domain_name
    origin_id                = "s3-${aws_s3_bucket.multi-tier-vpc-html.id}"   
    origin_access_control_id = aws_cloudfront_origin_access_control.multi-tier-vpc-html.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }
}

default_cache_behavior {
    target_origin_id       = "s3-${aws_s3_bucket.static_site.id}"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    compress = true

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }


data "aws_iam_policy_document" "allow_cloudfront_to_read_static_site" {
  statement {
    sid    = "AllowCloudFrontReadOnlyStaticSitePrefix"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.static_site.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.static_site.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "static_site" {
  bucket = aws_s3_bucket.static_site.id
  policy = data.aws_iam_policy_document.allow_cloudfront_to_read_static_site.json
}

