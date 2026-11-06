# Plan-only tests for scaling_approach = "request_count". The mocked provider means no AWS
# credentials are needed: run with `terraform test` from the repo root.

mock_provider "aws" {}

# Distinct policy ARNs known at plan time, so tests can check which policy an alarm triggers.
override_resource {
  target          = aws_appautoscaling_policy.request_count_scale_up_policy
  override_during = plan
  values = {
    arn = "arn:aws:autoscaling:us-east-1:123456789012:scalingPolicy:scale-up"
  }
}

override_resource {
  target          = aws_appautoscaling_policy.request_count_scale_down_policy
  override_during = plan
  values = {
    arn = "arn:aws:autoscaling:us-east-1:123456789012:scalingPolicy:scale-down"
  }
}

variables {
  organization         = "example"
  environment          = "dev"
  product              = "tftest-svc"
  owner                = "plops"
  repo                 = "https://github.com/pbs/terraform-aws-ecs-service-module.git"
  create_lb            = false
  cluster              = "test-cluster"
  task_def_arn         = "arn:aws:ecs:us-east-1:123456789012:task-definition/test:1"
  vpc_id               = "vpc-12345678"
  private_subnets      = ["subnet-11111111"]
  public_subnets       = ["subnet-22222222"]
  scaling_approach     = "request_count"
  alb_arn              = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/test-alb/50dc6c495c0c9188"
  alb_target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/test-tg/73e2d6bc24d8a067"
}

# ── Additional scale-up alarms ───────────────────────────────────────────────

run "no_additional_alarms_by_default" {
  command = plan
  assert {
    condition     = length(aws_cloudwatch_metric_alarm.additional_scale_up) == 0
    error_message = "No extra scale-up alarms may be created by default."
  }
}

run "additional_alarm_triggers_request_count_scale_up_policy" {
  command = plan

  variables {
    additional_scale_up_alarms = [{
      name                = "upstream"
      threshold           = 5000
      evaluation_periods  = 2
      datapoints_to_alarm = 1
      metric_queries = [{
        id          = "upstream_requests"
        return_data = true
        metric = {
          namespace   = "AWS/ApplicationELB"
          metric_name = "RequestCount"
          dimensions = {
            LoadBalancer = "app/upstream-alb/1111111111111111"
            TargetGroup  = "targetgroup/upstream-tg/2222222222222222"
          }
        }
      }]
    }]
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.additional_scale_up["upstream"].alarm_name == "tftest-svc-upstream-scale-up"
    error_message = "Extra alarm must be named <name>-<alarm name>-scale-up."
  }
  assert {
    condition     = aws_cloudwatch_metric_alarm.additional_scale_up["upstream"].alarm_actions == toset(["arn:aws:autoscaling:us-east-1:123456789012:scalingPolicy:scale-up"])
    error_message = "Extra alarm must trigger the request_count scale-up policy."
  }
  assert {
    condition     = [for q in aws_cloudwatch_metric_alarm.additional_scale_up["upstream"].metric_query : q.metric[0].metric_name] == ["RequestCount"]
    error_message = "Extra alarm must render its metric_queries."
  }
  assert {
    condition     = aws_cloudwatch_metric_alarm.additional_scale_up["upstream"].datapoints_to_alarm == 1 && aws_cloudwatch_metric_alarm.additional_scale_up["upstream"].evaluation_periods == 2
    error_message = "Extra alarm must use its own evaluation_periods and datapoints_to_alarm."
  }
  assert {
    condition     = length(aws_cloudwatch_metric_alarm.request_count_high) == 1
    error_message = "The per-task alarm must stay in place alongside extra alarms."
  }
}

run "additional_alarm_with_math_expression" {
  command = plan

  variables {
    additional_scale_up_alarms = [{
      name      = "ratio"
      threshold = 2
      metric_queries = [
        {
          id = "up"
          metric = {
            namespace   = "AWS/ApplicationELB"
            metric_name = "RequestCount"
            dimensions  = { LoadBalancer = "app/upstream-alb/1111111111111111" }
          }
        },
        { id = "ratio", expression = "up / 1000", label = "Upstream kRPM", return_data = true },
      ]
    }]
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.additional_scale_up["ratio"].metric_query) == 2
    error_message = "Extra alarm must render every metric query, including expressions."
  }
  assert {
    condition     = { for q in aws_cloudwatch_metric_alarm.additional_scale_up["ratio"].metric_query : q.id => length(q.metric) } == { up = 1, ratio = 0 }
    error_message = "An expression query must render without a metric block; a metric query must render exactly one."
  }
}

run "additional_alarms_reject_unsupported_approach" {
  command = plan
  variables {
    scaling_approach           = "target_tracking"
    additional_scale_up_alarms = [{ name = "a", threshold = 1, metric_queries = [{ id = "q", return_data = true, expression = "1" }] }]
  }
  expect_failures = [var.additional_scale_up_alarms]
}

# ── Proportional scale-up steps ──────────────────────────────────────────────

# step_adjustment is a set and its bounds are strings in the provider schema, so steps are
# compared as "lower..upper:adjustment" strings.
run "default_scale_up_is_single_step" {
  command = plan

  assert {
    condition = toset([
      for s in aws_appautoscaling_policy.request_count_scale_up_policy[0].step_scaling_policy_configuration[0].step_adjustment :
      "${s.metric_interval_lower_bound}..${s.metric_interval_upper_bound == null ? "inf" : s.metric_interval_upper_bound}:${s.scaling_adjustment}"
    ]) == toset(["0..inf:2"])
    error_message = "Without scale_up_steps the policy must keep one step of scale_up_adjustment tasks from lower bound 0."
  }
}

# The 0–50% / 50–100% / >100% example for alb_scale_up_threshold = 140 (the default), with small adjustments.
run "proportional_steps_render_in_order" {
  command = plan

  variables {
    scale_up_steps = [
      { lower_bound = 0, upper_bound = 70, adjustment = 1 },
      { lower_bound = 70, upper_bound = 140, adjustment = 2 },
      { lower_bound = 140, adjustment = 4 },
    ]
  }

  assert {
    condition = toset([
      for s in aws_appautoscaling_policy.request_count_scale_up_policy[0].step_scaling_policy_configuration[0].step_adjustment :
      "${s.metric_interval_lower_bound}..${s.metric_interval_upper_bound == null ? "inf" : s.metric_interval_upper_bound}:${s.scaling_adjustment}"
    ]) == toset(["0..70:1", "70..140:2", "140..inf:4"])
    error_message = "Each scale_up_steps entry must render as its own step_adjustment."
  }
}

run "steps_must_start_at_zero" {
  command = plan
  variables {
    scale_up_steps = [{ lower_bound = 10, adjustment = 5 }]
  }
  expect_failures = [var.scale_up_steps]
}

run "last_step_must_be_open_ended" {
  command = plan
  variables {
    scale_up_steps = [{ lower_bound = 0, upper_bound = 70, adjustment = 5 }]
  }
  expect_failures = [var.scale_up_steps]
}

run "step_adjustments_must_be_positive" {
  command = plan
  variables {
    scale_up_steps = [{ lower_bound = 0, adjustment = -1 }]
  }
  expect_failures = [var.scale_up_steps]
}

run "steps_reject_unsupported_approach" {
  command = plan
  variables {
    scaling_approach = "target_tracking"
    scale_up_steps   = [{ lower_bound = 0, adjustment = 2 }]
  }
  expect_failures = [var.scale_up_steps]
}

# ── Alarm tuning ─────────────────────────────────────────────────────────────

run "default_alarms_match_previous_behaviour" {
  command = plan

  assert {
    condition     = aws_cloudwatch_metric_alarm.request_count_high[0].metric_name == "RequestCountPerTarget" && aws_cloudwatch_metric_alarm.request_count_low[0].metric_name == "RequestCountPerTarget"
    error_message = "Both alarms must default to RequestCountPerTarget."
  }
  assert {
    condition     = aws_cloudwatch_metric_alarm.request_count_high[0].datapoints_to_alarm == 1 && aws_cloudwatch_metric_alarm.request_count_low[0].datapoints_to_alarm == 1
    error_message = "Both alarms must default to datapoints_to_alarm = 1."
  }
  assert {
    condition     = aws_cloudwatch_metric_alarm.request_count_high[0].treat_missing_data == "missing" && aws_cloudwatch_metric_alarm.request_count_low[0].treat_missing_data == "missing"
    error_message = "Both alarms must default to treat_missing_data = missing, the AWS default."
  }
  assert {
    condition     = aws_cloudwatch_metric_alarm.request_count_high[0].alarm_description == "Scale up tftest-svc based on ALB RequestCountPerTarget"
    error_message = "The default scale-up description must not change, to avoid an in-place update."
  }
  assert {
    condition     = aws_cloudwatch_metric_alarm.request_count_low[0].alarm_description == "Scale down tftest-svc based on ALB RequestCountPerTarget"
    error_message = "The default scale-down description must not change, to avoid an in-place update."
  }
}

run "alarm_tuning_inputs_apply" {
  command = plan

  variables {
    alb_metric_name              = "RequestCount"
    scaling_evaluation_periods   = 3
    alb_up_datapoints_to_alarm   = 2
    alb_down_datapoints_to_alarm = 3
    alb_up_treat_missing_data    = "notBreaching"
    alb_down_treat_missing_data  = "breaching"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.request_count_high[0].metric_name == "RequestCount" && aws_cloudwatch_metric_alarm.request_count_low[0].metric_name == "RequestCount"
    error_message = "alb_metric_name must apply to both alarms."
  }
  assert {
    condition     = aws_cloudwatch_metric_alarm.request_count_high[0].datapoints_to_alarm == 2 && aws_cloudwatch_metric_alarm.request_count_low[0].datapoints_to_alarm == 3
    error_message = "Datapoints to alarm must apply per direction."
  }
  assert {
    condition     = aws_cloudwatch_metric_alarm.request_count_high[0].treat_missing_data == "notBreaching" && aws_cloudwatch_metric_alarm.request_count_low[0].treat_missing_data == "breaching"
    error_message = "Treat missing data must apply per direction."
  }
  assert {
    condition     = aws_cloudwatch_metric_alarm.request_count_high[0].dimensions == tomap({ LoadBalancer = "app/test-alb/50dc6c495c0c9188", TargetGroup = "targetgroup/test-tg/73e2d6bc24d8a067" })
    error_message = "RequestCount must keep the LoadBalancer + TargetGroup dimensions, so it counts only this service's requests."
  }
}

run "metric_name_is_validated" {
  command = plan
  variables {
    alb_metric_name = "TargetResponseTime"
  }
  expect_failures = [var.alb_metric_name]
}

run "datapoints_cannot_exceed_evaluation_periods" {
  command = plan
  variables {
    scaling_evaluation_periods = 2
    alb_up_datapoints_to_alarm = 3
  }
  expect_failures = [var.alb_up_datapoints_to_alarm]
}

run "treat_missing_data_is_validated" {
  command = plan
  variables {
    alb_down_treat_missing_data = "zero"
  }
  expect_failures = [var.alb_down_treat_missing_data]
}
