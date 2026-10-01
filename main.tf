resource "aws_ecs_service" "service" {
  name                   = local.name
  cluster                = local.cluster
  task_definition        = local.task_def_arn
  launch_type            = local.use_capacity_provider_strategy ? null : var.launch_type
  desired_count          = local.desired_count
  enable_execute_command = local.enable_execute_command
  platform_version       = local.platform_version

  deployment_maximum_percent         = local.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  dynamic "capacity_provider_strategy" {
    for_each = local.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
    }
  }

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
    security_groups  = concat([aws_security_group.service_sg.id], var.extra_service_security_group_ids)
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

    precondition {
      condition     = !(local.use_capacity_provider_strategy && var.cluster == null && var.cluster_ec2_backed)
      error_message = "fargate_weight/fargate_spot_weight cannot be combined with cluster_ec2_backed = true on the module-managed cluster: that cluster already manages its own aws_ecs_cluster_capacity_providers for its EC2 capacity provider, and this module does not extend it to also associate FARGATE/FARGATE_SPOT. Provide an existing `cluster` that already has FARGATE and FARGATE_SPOT associated instead."
    }
  }

  depends_on = [
    aws_lb.lb,
    module.task,
    aws_ecs_cluster_capacity_providers.fargate_capacity_providers
  ]

  tags = local.tags
}
