variable "name" {
  description = "Name of the service. Will default to product if not defined."
  default     = null
  type        = string
}

variable "deployment_maximum_percent" {
  description = "The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment"
  default     = 150
  type        = number
}

variable "deployment_minimum_healthy_percent" {
  description = "The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment"
  default     = 100
  type        = number
}

variable "min_capacity" {
  description = "The minimum capacity of tasks for this service"
  default     = 1
  type        = number
}

variable "max_capacity" {
  description = "The maximum capacity of tasks for this service"
  default     = 2
  type        = number
}

variable "scale_up_cooldown" {
  description = "Scale up cooldown in minutes"
  default     = 1
  type        = number
}

variable "scale_up_adjustment" {
  description = "Tasks to add on scale up"
  default     = 2
  type        = number
}

variable "scale_down_cooldown" {
  description = "Scale down cooldown in minutes"
  default     = 5
  type        = number
}

variable "scale_down_adjustment" {
  description = "Tasks to add on scale up"
  default     = -1
  type        = number
}

variable "scaling_evaluation_period" {
  description = "Scaling evaluation period in seconds"
  default     = 60
  type        = number
}

variable "scaling_evaluation_periods" {
  description = "Number of periods over which data is compared to the threshold"
  default     = 1
  type        = number
}

variable "scaling_approach" {
  description = "Approach to take with scaling. Valid values are `target_tracking` and `step_scaling`"
  default     = "target_tracking"
  type        = string
  validation {
    condition     = contains(["target_tracking", "step_scaling"], var.scaling_approach)
    error_message = "Scaling approach must be either `target_tracking` or `step_scaling`."
  }
}

variable "target_cpu_utilization" {
  description = "Target CPU utilization for scaling"
  default     = 50
  type        = number
}

variable "target_memory_utilization" {
  description = "Target memory utilization for scaling"
  default     = 50
  type        = number
}

variable "target_requests_count_per_target" {
  description = "Target requests count per targe for scaling"
  default     = 800
  type        = number
}

variable "scale_up_cpu_threshold" {
  description = "Threshold at which CPU utilization triggers a scale up event"
  default     = 80
  type        = number
}

variable "scale_down_cpu_threshold" {
  description = "Threshold at which CPU utilization triggers a scale down event"
  default     = 20
  type        = number
}

variable "scale_up_memory_threshold" {
  description = "Threshold at which Memory utilization triggers a scale up event"
  default     = 80
  type        = number
}

variable "scale_down_memory_threshold" {
  description = "Threshold at which Memory utilization triggers a scale down event"
  default     = 20
  type        = number
}

variable "scale_up_requests_count_per_target" {
  description = "Threshold at which Request count per target triggers a scale up event"
  default     = 140
  type        = number
}

variable "scale_down_requests_count_per_target" {
  description = "Threshold at which Request count per target triggers a scale down event"
  default     = 70
  type        = number
}

variable "requests_count_scaling" {
  description = "Use RequestCountPerTarget CloudWatch metric for scaling"
  default     = false
  type        = bool
}

variable "container_protocol" {
  description = "Protocol to use in connection to the container"
  default     = "HTTP"
  type        = string
}

variable "healthcheck_healthy_threshold" {
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy"
  default     = 3
  type        = number
}

variable "healthcheck_unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering the target unhealthy"
  default     = 3
  type        = number
}

variable "healthcheck_timeout" {
  description = "The amount of time, in seconds, during which no response means a failed health check"
  default     = 6
  type        = number
}

variable "healthcheck_path" {
  description = "The destination for the health check request"
  default     = null
  type        = string
}

variable "healthcheck_protocol" {
  description = "The protocol to use to connect with the target"
  default     = null
  type        = string
}

variable "healthcheck_interval" {
  description = "The approximate amount of time, in seconds, between health checks of an individual target"
  default     = 10
  type        = number
}

variable "healthcheck_matcher" {
  description = "The HTTP codes to use when checking for a successful response from a target"
  default     = 200
  type        = number
}

variable "launch_type" {
  description = "The launch type on which to run your service"
  default     = "FARGATE"
  type        = string
}

variable "propagate_tags" {
  description = "Specifies whether to propagate the tags from the task definition or the service to the tasks"
  default     = "SERVICE"
  type        = string
}

variable "platform_version" {
  description = "The platform version on which to run your service"
  default     = "LATEST"
  type        = string
}

variable "restricted_cidr_blocks" {
  description = "CIDR blocks to receive restricted service access. If empty, no CIDRs will be allowed to connect."
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

variable "restricted_sg" {
  description = "SG to receive restricted service access. If null, no sg will be configured to connect"
  default     = null
  type        = string
}

variable "cluster" {
  description = "Name of the ECS Cluster this service runs in. If null, one will be created based on the product"
  default     = null
  type        = string
}

variable "assign_public_ip" {
  description = "Assign public IP to the service"
  default     = true
  type        = bool
}

variable "target_group_name" {
  description = "Target group name. Will default to product if not defined."
  default     = null
  type        = string
}

variable "load_balancer_name" {
  description = "Load balancer name. Will default to product if not defined."
  default     = null
  type        = string
}

variable "aliases" {
  description = "CNAME(s) that are allowed to be used for this service. Default is `product`.`hosted_zone`. e.g. [product.example.com] --> [product.example.com]"
  default     = null
  type        = list(string)
}

variable "cnames" {
  description = "CNAME(s) that are going to be created for this service in the hosted_zone. This can be set to [] to avoid creating a CNAME for the app. This can be useful for CDNs. Default is `product`. e.g. [product] --> [product.example.com]"
  default     = null
  type        = list(string)
}

variable "task_def_arn" {
  description = "Task definition ARN. If null, task will be created with default values, except that image_repo and image_tag may be defined."
  default     = null
  type        = string
}

variable "subnets" {
  description = "Subnets for the service. If null, private and public subnets will be looked up based on environment tag and one will be selected based on public_service."
  default     = null
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnets for the service. If null, private subnets will be looked up based on environment tag and will be selected based on public_service."
  default     = null
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnets for the service. If null, public subnets will be looked up based on environment tag and will be selected based on public_service."
  default     = null
  type        = list(string)
}

variable "public_service" {
  description = "Service should be provisioned in public subnet. Ignored if subnets defined."
  default     = false
  type        = bool
}

variable "internal" {
  description = "Use an internal load balancer. If null, will be internal when the service is private."
  default     = null
  type        = bool
}

variable "vpc_id" {
  description = "VPC ID. If null, one will be looked up based on environment tag."
  default     = null
  type        = string
}

variable "hosted_zone" {
  description = "Name of the hosted zone for DNS. e.g. hosted_zone = example.org --> service.example.org. Based on the is_hosted_zone_private, this is the primary or the private hosted zone."
  default     = null
  type        = string
}

variable "is_hosted_zone_private" {
  description = "Is the route53 zone private or not."
  default     = false
  type        = bool
}

variable "load_balancer_type" {
  description = "Type of load balancer to use. application, network or gateway."
  default     = "application"
  type        = string
}

variable "nlb_protocol" {
  description = "Protocol for the network load balancer used in this service. Ignored for application load balancers."
  default     = "TLS"
  type        = string
}

variable "http_port" {
  description = "HTTP port number."
  default     = "80"
  type        = number
}

variable "https_port" {
  description = "HTTPS port number."
  default     = "443"
  type        = number
}

variable "http_redirect" {
  description = "Redirect HTTP traffic to HTTPS. If set to false, HTTP traffic will be forwarded to the target groups"
  default     = true
  type        = bool
}

variable "tcp_port" {
  description = "NLB TCP port number. Ignored for application load balancers."
  default     = null
  type        = number
}

variable "role_policy_json" {
  description = "(optional) IAM policy to attach to role used for this task and replace defaults"
  default     = null
  type        = string
}

variable "task_execution_role_policy_json" {
  description = "(optional) IAM policy to attach to task execution role used for this task and replace defaults"
  default     = null
  type        = string
}

variable "extra_role_policy_json" {
  description = "(optional) Extra IAM policy to attach to role used for this task without replacing defaults"
  default     = null
  type        = string
}

variable "extra_task_execution_role_policy_json" {
  description = "(optional) Extra IAM policy to attach to task execution role used for this task without replacing defaults"
  default     = null
  type        = string
}

variable "enable_execute_command" {
  description = "Enables `ecs exec`. If null, will enable if not on prod"
  default     = null
  type        = bool
}

variable "enable_circuit_breaker" {
  description = "Enables ECS circuit breaker"
  default     = true
  type        = bool
}

variable "enable_circuit_breaker_rollback" {
  description = "Enables ECS circuit breaker rollback"
  default     = true
  type        = bool
}

variable "newrelic_secret_arn" {
  description = "ARN for AWS Secrets Manager secret of New Relic Insights insert key."
  default     = null
  type        = string
}

variable "newrelic_secret_name" {
  description = "Name for AWS Secrets Manager secret of New Relic Insights insert key."
  default     = null
  type        = string
}

variable "create_lb" {
  description = "Create load balancer for service. If creating a virtual node, will ignore value."
  default     = true
  type        = bool
}

variable "namespace_id" {
  description = "Namespace ID."
  type        = string
  default     = null
}

variable "dns_evaluate_target_health" {
  description = "evaluate health of endpoints by querying DNS records"
  default     = false
  type        = bool
}

variable "alpn_policy" {
  description = "Name of the Application-Layer Protocol Negotiation (ALPN) policy. Can be set if protocol is TLS. Valid values are HTTP1Only, HTTP2Only, HTTP2Optional, HTTP2Preferred, and None."
  default     = "HTTP2Preferred"
  type        = string
}

variable "alb_ssl_policy" {
  description = "SSL policy to use for an Application Load Balancer application."
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  type        = string
}

variable "nlb_ssl_policy" {
  description = "SSL policy to use for a Network Load Balancer application."
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  type        = string
}

variable "acm_arn" {
  description = "ARN of the ACM certificate to use for the service. If null, one will be guessed based on the primary hosted zone of the service."
  default     = null
  type        = string
}

variable "idle_timeout" {
  description = "Idle timeout for the load balancer. If null, will use whatever the default is for the load balancer type."
  default     = null
  type        = number
}

variable "load_balancer_sg_name" {
  description = "Prefix for the name of the load balancer security group. If null, will use `$${local.load_balancer_name}-sg-`."
  default     = null
  type        = string
}

variable "service_sg_name" {
  description = "Prefix for the name of the service security group. If null, will use `$${local.name}-service-sg-`."
  default     = null
  type        = string
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing for NLBs. ALB have this enabled by default and cannot be disabled."
  default     = true
  type        = string
}

variable "route_priority" {
  description = "Starting route priority, incremented by each listener rule"
  default     = 10
  type        = number
}

variable "create_attach_eip_to_nlb" {
  description = "Create EIPs for each subnet and attach them to the NLB (public only)"
  default     = false
  type        = bool
}
