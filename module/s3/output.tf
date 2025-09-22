output "MESSAGING_BUCKET_NAME" {
  value = aws_s3_bucket.project.id
}
output "MESSAGING_BUCKET_ARN" {
  value = aws_s3_bucket.project.arn
}
