data "aws_route53_zone" "hosted_zone" {
  count        = local.lookup_hosted_zone ? 1 : 0
  name         = "${var.hosted_zone}."
  private_zone = var.is_hosted_zone_private
}

data "aws_vpc" "vpc" {
  count = var.vpc_id == null ? 1 : 0
  tags = {
    "Name" : "*${var.environment}*"
  }
}

data "aws_subnets" "public_subnets" {
  count = var.public_subnets == null ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*-public-*"]
  }
}

data "aws_subnets" "private_subnets" {
  count = var.private_subnets == null ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*-private-*"]
  }
}

data "aws_acm_certificate" "primary_acm_wildcard_cert" {
  count  = local.lookup_primary_acm_wildcard_cert ? 1 : 0
  domain = "*.${var.hosted_zone}"
}
