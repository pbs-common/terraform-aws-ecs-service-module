# terraform {
#   backend "s3" {
#     bucket         = "pbs-digi-edcar-tfstate"
#     key            = "example-ecs-service-redirect/example-ecs-service-redirect.tfstate"
#     dynamodb_table = "example-ecs-service-redirect-lock"
#     region         = "us-east-1"
#     profile        = "pbs-digi-edcar"
#     encrypt        = true
#   }
# }
