
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