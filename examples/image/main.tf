module "service" {
  source = "../.."

  hosted_zone    = var.hosted_zone
  public_service = true

  image_repo = "nginx"
  image_tag  = "latest"

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}
