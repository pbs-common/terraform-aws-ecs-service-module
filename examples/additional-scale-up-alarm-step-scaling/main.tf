module "service" {
  source = "../.."

  hosted_zone = var.hosted_zone

  # CPU-based step scaling, with an extra alarm on the upstream service's request volume.
  scaling_approach = "step_scaling"
  min_capacity     = 2
  max_capacity     = 10

  additional_scale_up_alarms = [{
    name               = "upstream-requests"
    threshold          = 5000
    evaluation_periods = 2
    metric_queries = [{
      id          = "requests"
      return_data = true
      metric = {
        namespace   = "AWS/ApplicationELB"
        metric_name = "RequestCount"
        dimensions = {
          LoadBalancer = var.upstream_load_balancer
          TargetGroup  = var.upstream_target_group
        }
      }
    }]
  }]

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}
