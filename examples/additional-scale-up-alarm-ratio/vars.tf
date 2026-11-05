variable "hosted_zone" {
  type        = string
  description = "Primary hosted zone for this service. Populate `TF_VAR_hosted_zone` before running any tests to have this value populated."
}

variable "upstream_load_balancer" {
  type        = string
  description = "`LoadBalancer` CloudWatch dimension of the ALB in front of the upstream service, such as `app/upstream-alb/1111111111111111`."
}

variable "service_load_balancer" {
  type        = string
  description = "`LoadBalancer` CloudWatch dimension of the ALB in front of this service, such as `app/service-alb/3333333333333333`."
}

variable "service_target_group" {
  type        = string
  description = "`TargetGroup` CloudWatch dimension of this service's target group, such as `targetgroup/service-tg/4444444444444444`."
}
