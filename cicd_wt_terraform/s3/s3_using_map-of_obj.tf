

resource "aws_s3_bucket" "testBkts" {
    # Transforms the list into a map using "name" as the key
    for_each = var.bucket_config
    bucket = each.value.name
}


resource "aws_s3_bucket_versioning" "testBktVersioing" {
    for_each = var.bucket_config
    bucket = aws_s3_bucket.testBkts[each.key].name
    versioning_configuration {
        status = "Suspended"
    }
}