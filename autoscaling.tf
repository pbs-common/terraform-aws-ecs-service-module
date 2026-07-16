resource "aws_appautoscaling_target" "autoscaling_target" {
  count              = var.scaling_approach != "none" ? 1 : 0
  resource_id        = "service/${local.cluster_name}/${local.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
}

resource "aws_appautoscaling_policy" "cpu_autoscaling_policy" {
  count              = var.scaling_approach == "target_tracking" && var.requests_count_scaling == false ? 1 : 0
  name               = "${local.name}-cpu-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.autoscaling_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.autoscaling_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.autoscaling_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = var.target_cpu_utilization
  }
}

resource "aws_appautoscaling_policy" "memory_autoscaling_policy" {
  count              = var.scaling_approach == "target_tracking" && var.requests_count_scaling == false ? 1 : 0
  name               = "${local.name}-memory-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.autoscaling_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.autoscaling_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.autoscaling_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = var.target_memory_utilization
  }
}

resource "aws_appautoscaling_policy" "requests_count_autoscaling_policy" {
  count              = var.scaling_approach == "target_tracking" && var.requests_count_scaling && local.create_lb ? 1 : 0
  name               = "${local.name}-requests-count-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.autoscaling_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.autoscaling_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.autoscaling_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.lb[0].arn_suffix}/${aws_lb_target_group.target_group[0].arn_suffix}"
    }

    target_value = var.target_requests_count_per_target
  }
}

resource "aws_appautoscaling_policy" "scale_up_policy" {
  count              = var.scaling_approach == "step_scaling" && var.requests_count_scaling == false ? 1 : 0
  name               = "${local.name}-scale-up-policy"
  resource_id        = "service/${local.cluster_name}/${local.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  service_namespace = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_up_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = var.scale_up_adjustment
    }
  }
}

resource "aws_appautoscaling_policy" "scale_down_policy" {
  count              = var.scaling_approach == "step_scaling" && var.requests_count_scaling == false ? 1 : 0
  name               = "${local.name}-scale-down-policy"
  resource_id        = "service/${local.cluster_name}/${local.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  service_namespace = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_down_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = var.scale_down_adjustment
    }
  }
}

# these two alarms are essentially an OR for scaling up - either will trigger scaling
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = var.scaling_approach == "step_scaling" && var.requests_count_scaling == false ? 1 : 0
  alarm_name          = "${local.name}-cpu-high"
  alarm_description   = "This alarm monitors ${local.name} CPU utilization for scaling up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.scaling_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.scaling_evaluation_period
  statistic           = "Average"
  threshold           = var.scale_up_cpu_threshold
  alarm_actions       = [aws_appautoscaling_policy.scale_up_policy[0].arn]

  dimensions = {
    ClusterName = local.cluster
    ServiceName = local.service.name
  }

  tags = merge(
    local.tags,
    { Name = "${local.name} CW Metric Alarm CPU High" },
  )
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count               = var.scaling_approach == "step_scaling" && var.requests_count_scaling == false ? 1 : 0
  alarm_name          = "${local.name}-memory-high"
  alarm_description   = "This alarm monitors ${local.name} web memory utilization for scaling up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.scaling_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.scaling_evaluation_period
  statistic           = "Average"
  threshold           = var.scale_up_memory_threshold
  alarm_actions       = [aws_appautoscaling_policy.scale_up_policy[0].arn]

  dimensions = {
    ClusterName = local.cluster
    ServiceName = local.service.name
  }

  tags = merge(
    local.tags,
    { Name = "${local.name} CW Metric Alarm Memory High" },
  )
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count               = var.scaling_approach == "step_scaling" && var.requests_count_scaling == false ? 1 : 0
  alarm_name          = "${local.name}-cpu-low"
  alarm_description   = "This alarm monitors ${local.name} web CPU utilization for scaling down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.scaling_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.scaling_evaluation_period
  statistic           = "Average"
  threshold           = var.scale_down_cpu_threshold
  alarm_actions       = [aws_appautoscaling_policy.scale_down_policy[0].arn]

  dimensions = {
    ClusterName = local.cluster
    ServiceName = local.service.name
  }

  tags = merge(
    local.tags,
    { Name = "${local.name} CW Metric Alarm CPU Low" },
  )
}

resource "aws_cloudwatch_metric_alarm" "memory_low" {
  count               = var.scaling_approach == "step_scaling" && var.requests_count_scaling == false ? 1 : 0
  alarm_name          = "${local.name}-memory-low"
  alarm_description   = "This alarm monitors ${local.name} web memory utilization for scaling down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.scaling_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.scaling_evaluation_period
  statistic           = "Average"
  threshold           = var.scale_down_memory_threshold
  alarm_actions       = [aws_appautoscaling_policy.scale_down_policy[0].arn]

  dimensions = {
    ClusterName = local.cluster
    ServiceName = local.service.name
  }

  tags = merge(
    local.tags,
    { Name = "${local.name} CW Metric Alarm Memory Low" },
  )
}

resource "aws_cloudwatch_metric_alarm" "requests_count_high" {
  count               = var.scaling_approach == "step_scaling" && var.requests_count_scaling == true ? 1 : 0
  alarm_name          = "${local.name}-request-count-high"
  alarm_description   = "This alarm monitors ${local.name} RequestCountPerTarget for scaling up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.scaling_evaluation_periods
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = var.scaling_evaluation_period
  statistic           = "Sum"
  threshold           = var.scale_up_requests_count_per_target
  alarm_actions       = [aws_appautoscaling_policy.requests_count_scale_up_policy[0].arn]

  dimensions = {
    LoadBalancer = aws_lb.lb[0].arn_suffix
    TargetGroup  = aws_lb_target_group.target_group[0].arn_suffix
  }

  tags = merge(
    local.tags,
    { Name = "${local.name} CW Metric Alarm RequestCountPerTarget" },
  )
}

resource "aws_cloudwatch_metric_alarm" "requests_count_low" {
  count               = var.scaling_approach == "step_scaling" && var.requests_count_scaling == true ? 1 : 0
  alarm_name          = "${local.name}-request-count-low"
  alarm_description   = "This alarm monitors ${local.name} RequestCountPerTarget for scaling down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.scaling_evaluation_periods
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = var.scaling_evaluation_period
  statistic           = "Sum"
  threshold           = var.scale_down_requests_count_per_target
  alarm_actions       = [aws_appautoscaling_policy.requests_count_scale_down_policy[0].arn]

  dimensions = {
    LoadBalancer = aws_lb.lb[0].arn_suffix
    TargetGroup  = aws_lb_target_group.target_group[0].arn_suffix
  }

  tags = merge(
    local.tags,
    { Name = "${local.name} CW Metric Alarm RequestCountPerTarget" },
  )
}

resource "aws_appautoscaling_policy" "requests_count_scale_up_policy" {
  count              = var.scaling_approach == "step_scaling" && var.requests_count_scaling == true ? 1 : 0
  name               = "${local.name}-request-count-scale-up-policy"
  resource_id        = "service/${local.cluster_name}/${local.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  service_namespace = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_up_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = var.scale_up_adjustment
    }
  }
}

resource "aws_appautoscaling_policy" "requests_count_scale_down_policy" {
  count              = var.scaling_approach == "step_scaling" && var.requests_count_scaling == true ? 1 : 0
  name               = "${local.name}-request-count-scale-down-policy"
  resource_id        = "service/${local.cluster_name}/${local.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  service_namespace = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_down_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = var.scale_down_adjustment
    }
  }
}

# ── SQS-based scaling (scaling_approach = "sqs") ─────────────────────────────

resource "aws_appautoscaling_policy" "sqs_scale_up_policy" {
  count              = var.scaling_approach == "sqs" ? 1 : 0
  name               = var.sqs_scale_up_policy_name != null ? var.sqs_scale_up_policy_name : "${local.name}-sqs-scale-up-policy"
  resource_id        = "service/${local.cluster_name}/${local.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_up_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = var.scale_up_adjustment
    }
  }
}

resource "aws_appautoscaling_policy" "sqs_scale_down_policy" {
  count              = var.scaling_approach == "sqs" ? 1 : 0
  name               = var.sqs_scale_down_policy_name != null ? var.sqs_scale_down_policy_name : "${local.name}-sqs-scale-down-policy"
  resource_id        = "service/${local.cluster_name}/${local.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_down_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = var.scale_down_adjustment
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "sqs_high" {
  count               = var.scaling_approach == "sqs" ? 1 : 0
  alarm_name          = var.sqs_alarm_high_name != null ? var.sqs_alarm_high_name : "${local.name}-sqs-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.sqs_visible_up_threshold
  alarm_description   = "Alarm when SQS messages exceed threshold for ${local.name}"
  treat_missing_data  = "missing"

  metric_query {
    id          = "sqs_messages"
    return_data = true
    label       = "SQS Messages"
    metric {
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesVisible"
      period      = 60
      stat        = "Sum"
      dimensions = {
        QueueName = var.sqs_queue_name
      }
    }
  }

  actions_enabled = true
  alarm_actions   = [aws_appautoscaling_policy.sqs_scale_up_policy[0].arn]

  tags = merge(
    local.tags,
    { Name = "${local.name} CW Metric Alarm SQS High" },
  )
}

resource "aws_cloudwatch_metric_alarm" "sqs_low" {
  count               = var.scaling_approach == "sqs" ? 1 : 0
  alarm_name          = var.sqs_alarm_low_name != null ? var.sqs_alarm_low_name : "${local.name}-sqs-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  threshold           = var.sqs_visible_down_threshold
  alarm_description   = "Alarm when SQS messages are below threshold for ${local.name}"
  treat_missing_data  = "missing"

  metric_query {
    id          = "sqs_messages"
    return_data = true
    label       = "SQS Messages"
    metric {
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesVisible"
      period      = 60
      stat        = "Sum"
      dimensions = {
        QueueName = var.sqs_queue_name
      }
    }
  }

  actions_enabled = true
  alarm_actions   = [aws_appautoscaling_policy.sqs_scale_down_policy[0].arn]

  tags = merge(
    local.tags,
    { Name = "${local.name} CW Metric Alarm SQS Low" },
  )
}

# ── ALB RequestCountPerTarget–based scaling (scaling_approach = "request_count") ────────

resource "aws_appautoscaling_policy" "request_count_scale_up_policy" {
  count              = var.scaling_approach == "request_count" ? 1 : 0
  name               = var.alb_scale_up_policy_name != null ? var.alb_scale_up_policy_name : "${local.name}-request-count-scale-up-policy"
  resource_id        = "service/${local.cluster_name}/${local.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_up_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = var.scale_up_adjustment
    }
  }
}

resource "aws_appautoscaling_policy" "request_count_scale_down_policy" {
  count              = var.scaling_approach == "request_count" ? 1 : 0
  name               = var.alb_scale_down_policy_name != null ? var.alb_scale_down_policy_name : "${local.name}-request-count-scale-down-policy"
  resource_id        = "service/${local.cluster_name}/${local.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_down_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = var.scale_down_adjustment
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "request_count_high" {
  count               = var.scaling_approach == "request_count" ? 1 : 0
  alarm_name          = var.alb_alarm_high_name != null ? var.alb_alarm_high_name : "${local.name}-request-count-high"
  alarm_description   = "Scale up ${local.name} based on ALB RequestCountPerTarget"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.scaling_evaluation_periods
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = var.scaling_evaluation_period
  statistic           = "Sum"
  threshold           = var.alb_scale_up_threshold
  datapoints_to_alarm = 1

  dimensions = {
    TargetGroup  = replace(local.alb_scaling_tg_arn, "/arn:.*?:targetgroup\\/(.*)/", "targetgroup/$1")
    LoadBalancer = replace(local.alb_scaling_arn, "/arn:.*?:loadbalancer\\/(.*)/", "$1")
  }

  actions_enabled = true
  alarm_actions   = [aws_appautoscaling_policy.request_count_scale_up_policy[0].arn]

  tags = merge(
    local.tags,
    { Name = "${local.name} CW Metric Alarm ALB Requests High" },
  )
}

resource "aws_cloudwatch_metric_alarm" "request_count_low" {
  count               = var.scaling_approach == "request_count" ? 1 : 0
  alarm_name          = var.alb_alarm_low_name != null ? var.alb_alarm_low_name : "${local.name}-request-count-low"
  alarm_description   = "Scale down ${local.name} based on ALB RequestCountPerTarget"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.scaling_evaluation_periods
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = var.scaling_evaluation_period
  statistic           = "Sum"
  threshold           = var.alb_scale_down_threshold
  datapoints_to_alarm = 1

  dimensions = {
    TargetGroup  = replace(local.alb_scaling_tg_arn, "/arn:.*?:targetgroup\\/(.*)/", "targetgroup/$1")
    LoadBalancer = replace(local.alb_scaling_arn, "/arn:.*?:loadbalancer\\/(.*)/", "$1")
  }

  actions_enabled = true
  alarm_actions   = [aws_appautoscaling_policy.request_count_scale_down_policy[0].arn]

  tags = merge(
    local.tags,
    { Name = "${local.name} CW Metric Alarm ALB Requests Low" },
  )
}
