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
    error_message = "Without request_count_scale_up_steps the policy must keep one step of scale_up_adjustment tasks from lower bound 0."
  }
}

# The 0–50% / 50–100% / >100% example for alb_scale_up_threshold = 140 (the default), with small adjustments.
run "proportional_steps_render_in_order" {
  command = plan

  variables {
    request_count_scale_up_steps = [
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
    error_message = "Each request_count_scale_up_steps entry must render as its own step_adjustment."
  }
}

run "steps_must_start_at_zero" {
  command = plan
  variables {
    request_count_scale_up_steps = [{ lower_bound = 10, adjustment = 5 }]
  }
  expect_failures = [var.request_count_scale_up_steps]
}

run "steps_must_be_contiguous" {
  command = plan
  variables {
    request_count_scale_up_steps = [
      { lower_bound = 0, upper_bound = 50, adjustment = 5 },
      { lower_bound = 70, adjustment = 10 },
    ]
  }
  expect_failures = [var.request_count_scale_up_steps]
}

run "last_step_must_be_open_ended" {
  command = plan
  variables {
    request_count_scale_up_steps = [{ lower_bound = 0, upper_bound = 70, adjustment = 5 }]
  }
  expect_failures = [var.request_count_scale_up_steps]
}

run "steps_must_not_be_empty" {
  command = plan
  variables {
    request_count_scale_up_steps = []
  }
  expect_failures = [var.request_count_scale_up_steps]
}

run "step_adjustments_must_be_positive" {
  command = plan
  variables {
    request_count_scale_up_steps = [{ lower_bound = 0, adjustment = -1 }]
  }
  expect_failures = [var.request_count_scale_up_steps]
}

run "step_bounds_must_ascend" {
  command = plan
  variables {
    request_count_scale_up_steps = [
      { lower_bound = 0, upper_bound = 0, adjustment = 5 },
      { lower_bound = 0, adjustment = 10 },
    ]
  }
  expect_failures = [var.request_count_scale_up_steps]
}
