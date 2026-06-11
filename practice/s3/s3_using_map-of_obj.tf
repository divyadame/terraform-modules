
variable "bucket_config" {
    type = map(object({
        env = string
        name = string
    }))
 #you can define this or below   
    # default = [
    #     { env = "prod", name = "prod_bucket" }
    #     { env = "qa", name = "qa_bucket" }
    # ]
default = {
    "prod" = {
        env = "prod"
        name = "prod-bucket" 
        }
    "qa" = {
        env = "qa"
        name = "qa_bucket" 
        }
    }
}

resource "aws_s3_bucket" "testBkts" {
    # Transforms the list into a map using "name" as the key
    for_each = var.bucket_config
    bucket = each.value.name
}


resource "aws_s3_bucket_versioning" "testBktVersioing" {
    for_each = var.bucket_config
    bucket = aws_s3_bucket.testBkts.[each.key].id
    versioning_configuration {
        status = "Suspended"
    }
}