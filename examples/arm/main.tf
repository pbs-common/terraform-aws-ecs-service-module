module "service" {
  source = "../.."

  hosted_zone = var.hosted_zone

  runtime_platform = {
    cpu_architecture = "ARM64"
  }

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}
