provider "aws" {
  region = "us-east-2"
}

# 🔹 S3 Bucket
resource "aws_s3_bucket" "website" {
  bucket = "sagarbhaipalam-12345"   # ⚠️ change if already exists
}

# 🔹 Disable Block Public Access (IMPORTANT)
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 🔹 Website Configuration
resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }
}

# 🔹¸ Bucket Policy (Public Read)
resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.website.id

  depends_on = [aws_s3_bucket_public_access_block.public]

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# 🔹 Upload index.html
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.website.id
  key    = "index.html"
  source = "./index.html"

}

# 🔹 Output Website URL
output "website_url" {
  value = aws_s3_bucket_website_configuration.site.website_endpoint
}