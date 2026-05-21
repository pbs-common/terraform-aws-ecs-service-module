resource "aws_security_group" "lb_sg" {
  count       = local.create_lb ? 1 : 0
  description = "Controls access to the ${local.name} load balancer"

  vpc_id      = local.vpc_id
  name_prefix = local.load_balancer_sg_name

  tags = merge(
    local.tags,
    { Name = "${local.name} LB SG" },
  )
}

resource "aws_security_group_rule" "lb_egress" {
  count             = local.create_lb ? 1 : 0
  security_group_id = aws_security_group.lb_sg[0].id
  description       = "Allow all traffic out"
  type              = "egress"
  protocol          = "-1"

  from_port = 0
  to_port   = 0

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "user_to_lb_http_cidrs" {
  count             = local.create_http_listeners && local.create_cidr_access_rule ? 1 : 0
  security_group_id = aws_security_group.lb_sg[0].id
  description       = "Allow HTTP traffic from the user to the lb for specific CIDRs"
  type              = "ingress"
  protocol          = "tcp"

  from_port = var.http_port
  to_port   = var.http_port

  cidr_blocks = var.lb_ingress_cidr_blocks
}

resource "aws_security_group_rule" "user_to_lb_http_sgs" {
  count             = local.create_http_listeners && local.create_sg_access_rule ? 1 : 0
  security_group_id = aws_security_group.lb_sg[0].id
  description       = "Allow HTTP traffic from the user to the lb for specific SGs"
  type              = "ingress"
  protocol          = "tcp"

  from_port = var.http_port
  to_port   = var.http_port

  source_security_group_id = var.restricted_sg
}

resource "aws_security_group_rule" "user_to_lb_https_cidrs" {
  count             = local.create_https_listeners && local.create_cidr_access_rule ? 1 : 0
  security_group_id = aws_security_group.lb_sg[0].id
  description       = "Allow HTTPS traffic from the user to the lb"
  type              = "ingress"
  protocol          = "tcp"

  from_port = var.https_port
  to_port   = var.https_port

  cidr_blocks = var.lb_ingress_cidr_blocks
}

resource "aws_security_group_rule" "user_to_lb_https_sgs" {
  count             = local.create_https_listeners && local.create_sg_access_rule ? 1 : 0
  security_group_id = aws_security_group.lb_sg[0].id
  description       = "Allow HTTPS traffic from the user to the lb"
  type              = "ingress"
  protocol          = "tcp"

  from_port = var.https_port
  to_port   = var.https_port

  source_security_group_id = var.restricted_sg
}

resource "aws_security_group_rule" "user_to_nlb_cidrs" {
  count             = local.create_nlb && local.create_cidr_access_rule ? 1 : 0
  security_group_id = aws_security_group.lb_sg[0].id
  description       = "Allow TCP traffic from the user to the nlb"
  type              = "ingress"
  protocol          = "tcp"

  from_port = var.tcp_port
  to_port   = var.tcp_port

  cidr_blocks = var.lb_ingress_cidr_blocks
}

resource "aws_security_group_rule" "user_to_nlb_sgs" {
  count             = local.create_nlb && local.create_sg_access_rule ? 1 : 0
  security_group_id = aws_security_group.lb_sg[0].id
  description       = "Allow TCP traffic from the user to the nlb"
  type              = "ingress"
  protocol          = "tcp"

  from_port = var.tcp_port
  to_port   = var.tcp_port

  source_security_group_id = var.restricted_sg
}

resource "aws_security_group" "service_sg" {
  description = "Controls access to the ${local.name} service resources"
  vpc_id      = local.vpc_id
  name_prefix = local.service_sg_name

  tags = merge(
    local.tags,
    { Name = "${local.name} Service SG" },
  )
}

## Allow All Traffic out anywhere for egress
resource "aws_security_group_rule" "service_egress" {
  security_group_id = aws_security_group.service_sg.id
  description       = "Allow all traffic out"
  type              = "egress"
  protocol          = "-1"

  from_port = 0
  to_port   = 0

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "lb_to_service" {
  count             = local.create_lb ? 1 : 0
  security_group_id = aws_security_group.service_sg.id
  description       = "Allow container port traffic from the lb to the ECS service"
  type              = "ingress"
  protocol          = "tcp"

  from_port = var.container_port
  to_port   = var.container_port

  source_security_group_id = aws_security_group.lb_sg[0].id
}

resource "aws_security_group_rule" "nlb_service_access_cidr" {
  count             = local.create_nlb && local.create_nlb_cidr_access_rule ? 1 : 0
  security_group_id = aws_security_group.service_sg.id
  description       = "Allow container port traffic to the ECS service for specific CIDR blocks"
  type              = "ingress"
  protocol          = "tcp"

  from_port = var.container_port
  to_port   = var.container_port

  cidr_blocks = var.lb_ingress_cidr_blocks
}

resource "aws_security_group_rule" "nlb_service_access_sg" {
  count             = local.create_nlb && local.create_nlb_sg_access_rule ? 1 : 0
  security_group_id = aws_security_group.service_sg.id
  description       = "Allow container port traffic to the ECS service for specific SGs"
  type              = "ingress"
  protocol          = "tcp"

  from_port = var.container_port
  to_port   = var.container_port

  source_security_group_id = var.restricted_sg
}

resource "aws_security_group_rule" "user_to_virtual_node_access_cidr" {
  count             = local.create_virtual_node_cidr_access_rule ? 1 : 0
  description       = "Allow container port traffic to the ECS service for CIDR block"
  security_group_id = aws_security_group.service_sg.id
  type              = "ingress"
  protocol          = "tcp"

  from_port = var.container_port
  to_port   = var.container_port

  cidr_blocks = var.virtual_node_cidr_blocks
}

resource "aws_security_group_rule" "user_to_virtual_node_access_sg" {
  count             = local.create_virtual_node_sg_access_rule ? 1 : 0
  security_group_id = aws_security_group.service_sg.id
  description       = "Allow container port traffic to the ECS service for specific SGs"
  type              = "ingress"
  protocol          = "tcp"

  from_port = var.container_port
  to_port   = var.container_port

  source_security_group_id = var.restricted_sg
}
