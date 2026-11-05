# terraform {
#   backend "s3" {
#     bucket         = "my-bucket-tfstate"
#     key            = "example-terraform-aws-ecs-service-additional-scale-up-alarm-ratio"
#     profile        = "my-profile"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-lock"
#   }
# }
