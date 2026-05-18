resource "aws_ecs_service" "service" {
  name                   = local.name
  cluster                = local.cluster
  task_definition        = local.task_def_arn
  launch_type            = var.launch_type
  desired_count          = local.desired_count
  enable_execute_command = local.enable_execute_command
  platform_version       = local.platform_version

  deployment_maximum_percent         = local.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  dynamic "load_balancer" {
    for_each = toset(local.create_lb ? [local.create_lb] : [])
    content {
      target_group_arn = aws_lb_target_group.target_group[0].id
      container_name   = local.container_name
      container_port   = var.container_port
    }
  }

  dynamic "service_registries" {
    for_each = toset(local.create_cloudmap_service ? [local.create_cloudmap_service] : [])
    content {
      registry_arn   = aws_service_discovery_service.service[0].arn
      container_name = local.container_name
    }
  }

  network_configuration {
    subnets          = var.lb_scheme == "public" && var.task_subnet_scheme == "public" ? local.public_subnets : local.private_subnets
    security_groups  = [aws_security_group.service_sg.id]
    assign_public_ip = var.task_subnet_scheme == "public" && var.lb_scheme == "public"
  }

  deployment_circuit_breaker {
    enable   = var.enable_circuit_breaker
    rollback = var.enable_circuit_breaker_rollback
  }

  propagate_tags = var.propagate_tags

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }

  depends_on = [
    aws_lb.lb,
    module.task
  ]

  tags = local.tags
}
