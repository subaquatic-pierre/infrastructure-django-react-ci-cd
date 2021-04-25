output "bucket_main" {
  value = aws_s3_bucket.main
}

output "cf_distribution_id_main" {
  value = aws_cloudfront_distribution.main.id
}
