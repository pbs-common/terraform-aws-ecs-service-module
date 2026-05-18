module "service" {
  source = "../.."

  hosted_zone = var.hosted_zone

  load_balancer_type = "network"
  nlb_protocol       = "TCP"
  tcp_port           = 1234

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}
