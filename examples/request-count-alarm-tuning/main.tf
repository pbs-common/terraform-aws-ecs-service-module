module "service" {
  source = "../.."

  hosted_zone = var.hosted_zone

  # Alarm on the target group's total requests, which does not drop when tasks are added, instead of
  # RequestCountPerTarget. Size both thresholds as totals per scaling_evaluation_period.
  scaling_approach         = "request_count"
  alb_metric_name          = "RequestCount"
  min_capacity             = 2
  max_capacity             = 20
  alb_scale_up_threshold   = 6000
  alb_scale_down_threshold = 1500

  # Scale up on the first breaching minute, but scale down only after three in a row. An ALB publishes no request
  # metrics for a period with no requests, so treat missing data as breaching to let an idle service scale down.
  scaling_evaluation_periods   = 3
  alb_up_datapoints_to_alarm   = 1
  alb_down_datapoints_to_alarm = 3
  alb_down_treat_missing_data  = "breaching"

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}
