module "service" {
  source = "../.."

  create_lb = false


  image_repo = "busybox"
  image_tag  = "latest"

  command = ["echo", "hello"]

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}
