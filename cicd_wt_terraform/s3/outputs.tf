# FIXED: Output blocks do not accept a 'for_each' argument directly.
# We use a 'for' loop expression inside the 'value' block instead.
output "s3_bucket_names" {
    description = "Map of bucket keys to their resolved S3 bucket names"
    value = { for k, v in aws_s3_bucket.testBkts : k => v.id }
}