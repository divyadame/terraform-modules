# locals {
#     bucket_name = "testbucket"
# }

# resource "random_id" "bkt_id" {
#     count = 4
#     byte_length = 4
# }
# resource "aws_s3_bucket" "testBkts" {
#     count = 4
#     bucket = "${local.bucket_name}-${random_id.bkt_id[count.index].hex}"
# }


# resource "aws_s3_bucket_versioning" "testBktVersioing" {
#     count = 4
#     bucket = aws_s3_bucket.testBkts[count.index].id
#     versioning_configuration {
#         status = "Suspended"
#     }
# }