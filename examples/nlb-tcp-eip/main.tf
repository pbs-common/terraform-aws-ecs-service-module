module "service" {
  source = "../.."

  hosted_zone    = var.hosted_zone
  public_service = true

  load_balancer_type = "network"
  nlb_protocol       = "TCP"
  tcp_port           = 1234

  is_hosted_zone_private   = false
  public_subnets           = ["subnet-1234567890123456"]
  create_attach_eip_to_nlb = true


  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}
