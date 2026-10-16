# Plan-only tests for the scale-up inputs shared by the step-scaling approaches: step_scaling
# (CPU/memory), sqs and request_count. request_count itself is covered in
# request_count_scaling.tftest.hcl. The mocked provider means no AWS credentials are needed.

mock_provider "aws" {}

# Distinct policy ARNs known at plan time, so tests can check which policy an alarm triggers.
override_resource {
  target          = aws_appautoscaling_policy.scale_up_policy
  override_during = plan
  values = {
    arn = "arn:aws:autoscaling:us-east-1:123456789012:scalingPolicy:step-scale-up"
  }
}

override_resource {
  target          = aws_appautoscaling_policy.sqs_scale_up_policy
  override_during = plan
  values = {
    arn = "arn:aws:autoscaling:us-east-1:123456789012:scalingPolicy:sqs-scale-up"
  }
}

variables {
  organization     = "example"
  environment      = "dev"
  product          = "tftest-svc"
  owner            = "plops"
  repo             = "https://github.com/pbs/terraform-aws-ecs-service-module.git"
  create_lb        = false
  cluster          = "test-cluster"
  task_def_arn     = "arn:aws:ecs:us-east-1:123456789012:task-definition/test:1"
  vpc_id           = "vpc-12345678"
  private_subnets  = ["subnet-11111111"]
  public_subnets   = ["subnet-22222222"]
  scaling_approach = "sqs"
  sqs_queue_name   = "work"
}

# ── Scale-up steps ───────────────────────────────────────────────────────────

# step_adjustment is a set and its bounds are strings in the provider schema, so steps are
# compared as "lower..upper:adjustment" strings.
run "sqs_default_scale_up_is_single_step" {
  command = plan

  assert {
    condition = toset([
      for s in aws_appautoscaling_policy.sqs_scale_up_policy[0].step_scaling_policy_configuration[0].step_adjustment :
      "${s.metric_interval_lower_bound}..${s.metric_interval_upper_bound == null ? "inf" : s.metric_interval_upper_bound}:${s.scaling_adjustment}"
    ]) == toset(["0..inf:2"])
    error_message = "Without scale_up_steps the SQS policy must keep one step of scale_up_adjustment tasks from lower bound 0."
  }
}

run "sqs_steps_render" {
  command = plan

  variables {
    scale_up_steps = [
      { lower_bound = 0, upper_bound = 100, adjustment = 1 },
      { lower_bound = 100, adjustment = 3 },
    ]
  }

  assert {
    condition = toset([
      for s in aws_appautoscaling_policy.sqs_scale_up_policy[0].step_scaling_policy_configuration[0].step_adjustment :
      "${s.metric_interval_lower_bound}..${s.metric_interval_upper_bound == null ? "inf" : s.metric_interval_upper_bound}:${s.scaling_adjustment}"
    ]) == toset(["0..100:1", "100..inf:3"])
    error_message = "scale_up_steps must render on the SQS scale-up policy."
  }
}

run "step_scaling_default_scale_up_is_single_step" {
  command = plan

  variables {
    scaling_approach = "step_scaling"
  }

  assert {
    condition = toset([
      for s in aws_appautoscaling_policy.scale_up_policy[0].step_scaling_policy_configuration[0].step_adjustment :
      "${s.metric_interval_lower_bound}..${s.metric_interval_upper_bound == null ? "inf" : s.metric_interval_upper_bound}:${s.scaling_adjustment}"
    ]) == toset(["0..inf:2"])
    error_message = "Without scale_up_steps the CPU/memory policy must keep one step of scale_up_adjustment tasks from lower bound 0."
  }
}

# CPU threshold 80: up to 10 points over adds 1 task, beyond that 2.
run "step_scaling_steps_render" {
  command = plan

  variables {
    scaling_approach = "step_scaling"
    scale_up_steps = [
      { lower_bound = 0, upper_bound = 10, adjustment = 1 },
      { lower_bound = 10, adjustment = 2 },
    ]
  }

  assert {
    condition = toset([
      for s in aws_appautoscaling_policy.scale_up_policy[0].step_scaling_policy_configuration[0].step_adjustment :
      "${s.metric_interval_lower_bound}..${s.metric_interval_upper_bound == null ? "inf" : s.metric_interval_upper_bound}:${s.scaling_adjustment}"
    ]) == toset(["0..10:1", "10..inf:2"])
    error_message = "scale_up_steps must render on the CPU/memory scale-up policy."
  }
}

# The legacy path's alarms index the module's own load balancer, so these runs create one, with no DNS records.
run "legacy_requests_count_scaling_rejects_steps" {
  command = plan
  variables {
    scaling_approach       = "step_scaling"
    requests_count_scaling = true
    create_lb              = true
    cnames                 = []
    scale_up_steps         = [{ lower_bound = 0, adjustment = 2 }]
  }
  expect_failures = [var.scale_up_steps]
}

run "custom_metric_step_scaling_rejects_steps" {
  command = plan
  variables {
    scaling_approach = "custom_metric_step_scaling"
    scale_up_steps   = [{ lower_bound = 0, adjustment = 2 }]
  }
  expect_failures = [var.scale_up_steps]
}

# ── Additional scale-up alarms ───────────────────────────────────────────────

run "sqs_additional_alarm_triggers_sqs_scale_up_policy" {
  command = plan

  variables {
    additional_scale_up_alarms = [{ name = "upstream", threshold = 1, metric_queries = [{ id = "q", return_data = true, expression = "1" }] }]
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.additional_scale_up["upstream"].alarm_actions == toset(["arn:aws:autoscaling:us-east-1:123456789012:scalingPolicy:sqs-scale-up"])
    error_message = "With scaling_approach sqs, an extra alarm must trigger the SQS scale-up policy."
  }
}

run "step_scaling_additional_alarm_triggers_step_scale_up_policy" {
  command = plan

  variables {
    scaling_approach           = "step_scaling"
    additional_scale_up_alarms = [{ name = "upstream", threshold = 1, metric_queries = [{ id = "q", return_data = true, expression = "1" }] }]
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.additional_scale_up["upstream"].alarm_actions == toset(["arn:aws:autoscaling:us-east-1:123456789012:scalingPolicy:step-scale-up"])
    error_message = "With scaling_approach step_scaling, an extra alarm must trigger the CPU/memory scale-up policy."
  }
}

run "legacy_requests_count_scaling_rejects_additional_alarms" {
  command = plan
  variables {
    scaling_approach           = "step_scaling"
    requests_count_scaling     = true
    create_lb                  = true
    cnames                     = []
    additional_scale_up_alarms = [{ name = "upstream", threshold = 1, metric_queries = [{ id = "q", return_data = true, expression = "1" }] }]
  }
  expect_failures = [var.additional_scale_up_alarms]
}

# ── Alarm tuning ─────────────────────────────────────────────────────────────

run "sqs_alarms_default_treat_missing_data" {
  command = plan
  assert {
    condition     = aws_cloudwatch_metric_alarm.sqs_high[0].treat_missing_data == "missing" && aws_cloudwatch_metric_alarm.sqs_low[0].treat_missing_data == "missing"
    error_message = "Both SQS alarms must keep treat_missing_data = missing by default."
  }
}

run "sqs_treat_missing_data_applies" {
  command = plan
  variables {
    sqs_up_treat_missing_data   = "notBreaching"
    sqs_down_treat_missing_data = "breaching"
  }
  assert {
    condition     = aws_cloudwatch_metric_alarm.sqs_high[0].treat_missing_data == "notBreaching" && aws_cloudwatch_metric_alarm.sqs_low[0].treat_missing_data == "breaching"
    error_message = "SQS treat missing data must apply per direction."
  }
}

run "sqs_treat_missing_data_is_validated" {
  command = plan
  variables {
    sqs_down_treat_missing_data = "zero"
  }
  expect_failures = [var.sqs_down_treat_missing_data]
}

run "cpu_memory_alarms_match_previous_behaviour" {
  command = plan
  variables {
    scaling_approach     = "step_scaling"
    memory_count_scaling = true
  }
  assert {
    condition = alltrue([
      for a in [aws_cloudwatch_metric_alarm.cpu_high[0], aws_cloudwatch_metric_alarm.cpu_low[0], aws_cloudwatch_metric_alarm.memory_high[0], aws_cloudwatch_metric_alarm.memory_low[0]] :
      a.datapoints_to_alarm == null && a.treat_missing_data == "missing"
    ])
    error_message = "CPU and memory alarms must keep datapoints_to_alarm unset and treat_missing_data = missing by default."
  }
}

run "cpu_memory_alarm_tuning_applies" {
  command = plan
  variables {
    scaling_approach                    = "step_scaling"
    memory_count_scaling                = true
    scaling_evaluation_periods          = 3
    cpu_memory_up_datapoints_to_alarm   = 2
    cpu_memory_down_datapoints_to_alarm = 3
    cpu_memory_up_treat_missing_data    = "notBreaching"
    cpu_memory_down_treat_missing_data  = "breaching"
  }
  assert {
    condition = alltrue([
      for a in [aws_cloudwatch_metric_alarm.cpu_high[0], aws_cloudwatch_metric_alarm.memory_high[0]] :
      a.datapoints_to_alarm == 2 && a.treat_missing_data == "notBreaching"
    ])
    error_message = "Scale-up tuning must apply to both the CPU and memory high alarms."
  }
  assert {
    condition = alltrue([
      for a in [aws_cloudwatch_metric_alarm.cpu_low[0], aws_cloudwatch_metric_alarm.memory_low[0]] :
      a.datapoints_to_alarm == 3 && a.treat_missing_data == "breaching"
    ])
    error_message = "Scale-down tuning must apply to both the CPU and memory low alarms."
  }
}

run "cpu_memory_datapoints_cannot_exceed_evaluation_periods" {
  command = plan
  variables {
    scaling_approach                  = "step_scaling"
    scaling_evaluation_periods        = 2
    cpu_memory_up_datapoints_to_alarm = 3
  }
  expect_failures = [var.cpu_memory_up_datapoints_to_alarm]
}

run "cpu_memory_treat_missing_data_is_validated" {
  command = plan
  variables {
    scaling_approach                 = "step_scaling"
    cpu_memory_up_treat_missing_data = "zero"
  }
  expect_failures = [var.cpu_memory_up_treat_missing_data]
}

run "custom_metric_datapoints_to_alarm" {
  command = plan
  variables {
    scaling_approach = "custom_metric_step_scaling"
    custom_metric_step_scaling = [
      {
        name       = "latency"
        scale_up   = { namespace = "Custom", metric_name = "Latency", threshold = 500, evaluation_periods = 3, datapoints_to_alarm = 2 }
        scale_down = { namespace = "Custom", metric_name = "Latency", threshold = 100 }
      },
    ]
  }
  assert {
    condition     = aws_cloudwatch_metric_alarm.custom_metric_high["latency"].datapoints_to_alarm == 2 && aws_cloudwatch_metric_alarm.custom_metric_low["latency"].datapoints_to_alarm == null
    error_message = "custom_metric_step_scaling must pass datapoints_to_alarm through, leaving it unset by default."
  }
}

run "custom_metric_datapoints_cannot_exceed_evaluation_periods" {
  command = plan
  variables {
    scaling_approach = "custom_metric_step_scaling"
    custom_metric_step_scaling = [
      {
        name       = "latency"
        scale_up   = { namespace = "Custom", metric_name = "Latency", threshold = 500, datapoints_to_alarm = 2 }
        scale_down = { namespace = "Custom", metric_name = "Latency", threshold = 100 }
      },
    ]
  }
  expect_failures = [var.custom_metric_step_scaling]
}
