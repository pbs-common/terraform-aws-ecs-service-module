module "service" {
  source = "../.."

  hosted_zone    = var.hosted_zone
  public_service = true

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}
