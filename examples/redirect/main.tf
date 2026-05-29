module "ecs_service" {
  source = "../.."

  # Required Parameters
  cluster      = aws_ecs_cluster.cluster.name
  task_def_arn = aws_ecs_task_definition.app.arn

  # Load Balancer Configuration
  create_lb          = true
  load_balancer_type = "application"
  lb_scheme          = "public"

  # Primary domain
  cnames                 = [var.product]
  aliases                = ["${var.product}.${var.hosted_zone}"]
  hosted_zone            = var.hosted_zone
  is_hosted_zone_private = false

  # Redirect rules for alternative domains/subdomains
  extra_https_listener_rules = [
    {
      host_headers         = ["old-app.${var.hosted_zone}", "legacy.${var.hosted_zone}"]
      redirect_host        = "${var.product}.${var.hosted_zone}"
      redirect_status_code = "HTTP_301"
      redirect_protocol    = "HTTPS"
    },
    {
      host_headers  = ["www.old-domain.${var.hosted_zone}"]
      redirect_host = "${var.product}.${var.hosted_zone}"
    }
  ]

  # Optional: HTTP redirect rules
  extra_http_listener_rules = [
    {
      host_headers      = ["old-app.${var.hosted_zone}"]
      redirect_host     = "${var.product}.${var.hosted_zone}"
      redirect_protocol = "HTTPS"
    }
  ]

  # Tagging Parameters
  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
  tags         = var.tags
}

# Minimal ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name = "${var.product}-${var.environment}"
  tags = {
    Name = "${var.product}-${var.environment}"
  }
}

# Minimal task definition
resource "aws_ecs_task_definition" "app" {
  family                   = var.product
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = var.product
      image     = "nginx:latest"
      cpu       = 256
      memory    = 512
      essential = true
    }
  ])
}
