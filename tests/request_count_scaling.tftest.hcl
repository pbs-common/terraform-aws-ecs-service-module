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
