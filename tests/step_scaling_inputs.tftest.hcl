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

# ── Plan sanity ────────────────────────────────────────────────────────────

run "step_scaling_with_null_requests_count_scaling_still_plans" {
  command = plan
  variables {
    scaling_approach       = "step_scaling"
    requests_count_scaling = null
  }
  assert {
    condition     = length(aws_appautoscaling_policy.scale_up_policy) == 0 && length(aws_cloudwatch_metric_alarm.additional_scale_up) == 0
    error_message = "A null requests_count_scaling must keep planning, with no step policies, as before."
  }
}
