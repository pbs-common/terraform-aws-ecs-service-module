variable "hosted_zone" {
  type        = string
  description = "Primary hosted zone for this service. Populate `TF_VAR_hosted_zone` before running any tests to have this value populated."
}

variable "upstream_load_balancer" {
  type        = string
  description = "`LoadBalancer` CloudWatch dimension of the ALB in front of the upstream service, such as `app/upstream-alb/1111111111111111`."
}

variable "upstream_target_group" {
  type        = string
  description = "`TargetGroup` CloudWatch dimension of the upstream service's target group, such as `targetgroup/upstream-tg/2222222222222222`."
}
