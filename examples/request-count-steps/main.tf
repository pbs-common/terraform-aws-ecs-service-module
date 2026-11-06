module "service" {
  source = "../.."

  hosted_zone = var.hosted_zone

  # Scale on the ALB's RequestCountPerTarget, and add more tasks the further it is over the threshold.
  scaling_approach       = "request_count"
  min_capacity           = 2
  max_capacity           = 20
  alb_scale_up_threshold = 140

  # Bounds are offsets from the threshold: 140-210 adds 1 task, 210-280 adds 2, and above 280 adds 4.
  scale_up_steps = [
    { lower_bound = 0, upper_bound = 70, adjustment = 1 },
    { lower_bound = 70, upper_bound = 140, adjustment = 2 },
    { lower_bound = 140, adjustment = 4 },
  ]

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}
