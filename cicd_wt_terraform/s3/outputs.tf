output "s3_bucket_name" {
    for_each = aws_s3_bucket.testBkts.id
    value = each.value
}