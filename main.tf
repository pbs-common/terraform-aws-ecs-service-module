resource "aws_ecs_service" "service" {
  count                  = var.ignore_task_definition_changes ? 0 : 1
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

  dynamic "load_balancer" {
    for_each = var.custom_target_group_arns
    content {
      target_group_arn = load_balancer.value
      container_name   = local.container_name
      container_port   = var.container_port
    }
  }

  health_check_grace_period_seconds = var.health_check_grace_period_seconds

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

  propagate_tags       = var.propagate_tags
  force_new_deployment = var.force_new_deployment

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

# Identical to aws_ecs_service.service, but also ignores task_definition changes.
# A second resource is required because lifecycle.ignore_changes cannot reference
# variables, so the toggle is expressed through count instead.
resource "aws_ecs_service" "service_ignore_task_definition" {
  count                  = var.ignore_task_definition_changes ? 1 : 0
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

  dynamic "load_balancer" {
    for_each = var.custom_target_group_arns
    content {
      target_group_arn = load_balancer.value
      container_name   = local.container_name
      container_port   = var.container_port
    }
  }

  health_check_grace_period_seconds = var.health_check_grace_period_seconds

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

  propagate_tags       = var.propagate_tags
  force_new_deployment = var.force_new_deployment

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition
    ]
  }

  depends_on = [
    aws_lb.lb,
    module.task
  ]

  tags = local.tags
}