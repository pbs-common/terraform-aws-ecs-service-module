module "service" {
  source = "../.."

  hosted_zone = var.hosted_zone

  scaling_approach = "request_count"
  min_capacity     = 2
  max_capacity     = 20

  # Also scale up when the upstream service's traffic per task of this service gets too high, before this service's
  # own RequestCountPerTarget alarm sees it. Both alarms trigger the same scale-up policy, so this can only
  # make the service scale up earlier, never later.
  additional_scale_up_alarms = [{
    name                = "upstream-requests-per-task"
    threshold           = 3500
    evaluation_periods  = 2
    datapoints_to_alarm = 2
    metric_queries = [
      {
        id = "requests"
        metric = {
          namespace   = "AWS/ApplicationELB"
          metric_name = "RequestCount"
          stat        = "Sum"
          dimensions  = { LoadBalancer = var.upstream_load_balancer }
        }
      },
      {
        id = "healthy"
        metric = {
          namespace   = "AWS/ApplicationELB"
          metric_name = "HealthyHostCount"
          stat        = "Average"
          dimensions = {
            LoadBalancer = var.service_load_balancer
            TargetGroup  = var.service_target_group
          }
        }
      },
      {
        id          = "per_task"
        expression  = "requests / healthy"
        label       = "Upstream requests per task per minute"
        return_data = true
      },
    ]
  }]

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}
