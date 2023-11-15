module "service" {
  source = "../.."

  hosted_zone = var.hosted_zone

  load_balancer_type = "network"

  // This is necessary because the NLB will
  // send HTTP2 traffic to NGINX despite terminating TLS.
  alpn_policy = "HTTP1Only"

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}
