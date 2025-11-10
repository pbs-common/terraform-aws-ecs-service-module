variable "hosted_zone" {
  type        = string
  description = "Primary hosted zone for this service. Populate `TF_VAR_hosted_zone` before running any tests to have this value populated."
}

module "service" {
  source = "../.."

  hosted_zone    = var.hosted_zone
  public_service = true
  cnames = [
    "example-ecs-service-multiple-cnames",
    "example-ecs-service-multiple-cnames2",
  ]

  organization = "example"
  environment  = "sharedtools"
  product      = "example-service-multiple-cnames"
  owner        = "plops"
  repo         = "https://github.com/pbs/terraform-ecs-service-module.git"
}

// We provide this as an output because our test suite checks this output as part of it's test assertion
output "domain_name" {
  value = module.service.domain_name
}