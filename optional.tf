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
  description = "Approach to take with scaling. Valid values are `target_tracking`, `step_scaling`, `sqs`, `alb` and `none`"
  default     = "target_tracking"
  type        = string
  validation {
    condition     = contains(["target_tracking", "step_scaling", "sqs", "alb", "none"], var.scaling_approach)
    error_message = "Scaling approach must be `target_tracking`, `step_scaling`, `sqs`, `alb` or `none`."
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

variable "force_new_deployment" {
  description = "Enable force a new task deployment of the service. Set to true when changing launch_type or capacity_provider_strategy."
  default     = false
  type        = bool
}

variable "platform_version" {
  description = "The platform version on which to run your service"
  default     = "LATEST"
  type        = string
}

variable "lb_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach the load balancer (HTTP/HTTPS ingress). Defaults to open internet access."
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

variable "virtual_node_cidr_blocks" {
  description = "CIDR blocks allowed to connect directly to the ECS task (App Mesh virtual node). Empty by default — only set for AppMesh/service mesh use cases."
  default     = []
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

variable "private_subnets" {
  description = "Private subnets for the service. If null, private subnets will be looked up based on environment tag."
  default     = null
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnets for the service. If null, public subnets will be looked up based on environment tag."
  default     = null
  type        = list(string)
}

variable "lb_scheme" {
  description = "Scheme for the load balancer and subnet selection. \"public\" creates an internet-facing LB in public subnets. \"internal\" creates an internal LB in private subnets."
  default     = "public"
  type        = string
  validation {
    condition     = contains(["public", "internal"], var.lb_scheme)
    error_message = "lb_scheme must be either \"public\" or \"internal\"."
  }
}

variable "task_subnet_scheme" {
  description = "Subnet placement for ECS tasks. \"private\" (default) places tasks in private subnets. \"public\" places tasks in public subnets. Only respected when lb_scheme is \"public\"; tasks are always private when lb_scheme is \"internal\"."
  default     = "private"
  type        = string
  validation {
    condition     = contains(["private", "public"], var.task_subnet_scheme)
    error_message = "task_subnet_scheme must be either \"private\" or \"public\"."
  }
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

variable "custom_http_headers" {
  description = "(optional) Custom HTTP headers for application load balancers. Format should be a list of maps with `name` and `value` keys. e.g. [{ name = \"header1\", value = \"value1\"}, { name = \"header2\", value = \"value2\"}]"
  default     = []
  type        = list(object({ name = string, value = string }))
}

variable "extra_https_listener_rules" {
  description = "(optional) Additional HTTPS listener rules to create for ALB host-header redirects. Each rule specifies host headers to match and redirect configuration. Priority is automatically assigned after application rules."
  default     = []
  type = list(object({
    host_headers         = list(string)
    redirect_protocol    = optional(string, "HTTPS")
    redirect_status_code = optional(string, "HTTP_301")
    redirect_host        = string
    redirect_path        = optional(string, "/")
    redirect_query       = optional(string, "")
  }))
  validation {
    condition = alltrue([
      for rule in var.extra_https_listener_rules :
      contains(["HTTP", "HTTPS"], rule.redirect_protocol)
    ])
    error_message = "redirect_protocol must be HTTP or HTTPS."
  }
  validation {
    condition = alltrue([
      for rule in var.extra_https_listener_rules :
      contains(["HTTP_301", "HTTP_302", "HTTP_303", "HTTP_307", "HTTP_308"], rule.redirect_status_code)
    ])
    error_message = "redirect_status_code must be HTTP_301, HTTP_302, HTTP_303, HTTP_307, or HTTP_308."
  }
}

variable "extra_http_listener_rules" {
  description = "(optional) Additional HTTP listener rules to create for ALB host-header redirects. Each rule specifies host headers to match and redirect configuration. Priority is automatically assigned after application rules."
  default     = []
  type = list(object({
    host_headers         = list(string)
    redirect_protocol    = optional(string, "HTTP")
    redirect_status_code = optional(string, "HTTP_301")
    redirect_host        = string
    redirect_path        = optional(string, "/")
    redirect_query       = optional(string, "")
  }))
  validation {
    condition = alltrue([
      for rule in var.extra_http_listener_rules :
      contains(["HTTP", "HTTPS"], rule.redirect_protocol)
    ])
    error_message = "redirect_protocol must be HTTP or HTTPS."
  }
  validation {
    condition = alltrue([
      for rule in var.extra_http_listener_rules :
      contains(["HTTP_301", "HTTP_302", "HTTP_303", "HTTP_307", "HTTP_308"], rule.redirect_status_code)
    ])
    error_message = "redirect_status_code must be HTTP_301, HTTP_302, HTTP_303, HTTP_307, or HTTP_308."
  }
}

variable "sqs_queue_name" {
  description = "Name of the SQS queue to use for SQS-based scaling. Required when scaling_approach is `sqs`"
  default     = ""
  type        = string
}

variable "sqs_alarm_high_name" {
  description = "Override name for the SQS high-watermark CloudWatch alarm. Defaults to `$${local.name}-sqs-high`."
  default     = null
  type        = string
}

variable "sqs_alarm_low_name" {
  description = "Override name for the SQS low-watermark CloudWatch alarm. Defaults to `$${local.name}-sqs-low`."
  default     = null
  type        = string
}

variable "sqs_scale_up_policy_name" {
  description = "Override name for the SQS scale-up autoscaling policy. Defaults to `$${local.name}-sqs-scale-up-policy`."
  default     = null
  type        = string
}

variable "sqs_scale_down_policy_name" {
  description = "Override name for the SQS scale-down autoscaling policy. Defaults to `$${local.name}-sqs-scale-down-policy`."
  default     = null
  type        = string
}

variable "sqs_visible_up_threshold" {
  description = "Number of visible SQS messages that triggers a scale-up event"
  default     = 100
  type        = number
}

variable "sqs_visible_down_threshold" {
  description = "Number of visible SQS messages below which a scale-down event is triggered"
  default     = 10
  type        = number
}

variable "custom_target_group_arns" {
  description = "List of existing ALB target group ARNs to attach to the service instead of creating a new load balancer."
  default     = []
  type        = list(string)
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks."
  default     = null
  type        = number
}

variable "alb_arn" {
  description = "ARN of the ALB used for ALB-based scaling. Required when `scaling_approach` is `alb` and `create_lb` is false. When `create_lb` is true the module's own ALB is used automatically."
  default     = null
  type        = string
}

variable "alb_target_group_arn" {
  description = "ARN of the ALB target group used for ALB-based scaling. Required when `scaling_approach` is `alb` and `create_lb` is false. When `create_lb` is true the module's own target group is used automatically."
  default     = null
  type        = string
}

variable "alb_scale_up_threshold" {
  description = "RequestCountPerTarget value that triggers a scale-up event when `scaling_approach` is `alb`."
  default     = 140
  type        = number
}

variable "alb_scale_down_threshold" {
  description = "RequestCountPerTarget value below which a scale-down event is triggered when `scaling_approach` is `alb`."
  default     = 70
  type        = number
}

variable "alb_alarm_high_name" {
  description = "Override name for the ALB scale-up CloudWatch alarm. Defaults to `${local.name}-alb-requests-high`."
  default     = null
  type        = string
}

variable "alb_alarm_low_name" {
  description = "Override name for the ALB scale-down CloudWatch alarm. Defaults to `${local.name}-alb-requests-low`."
  default     = null
  type        = string
}

variable "alb_scale_up_policy_name" {
  description = "Override name for the ALB scale-up autoscaling policy. Defaults to `${local.name}-alb-scale-up-policy`."
  default     = null
  type        = string
}

variable "alb_scale_down_policy_name" {
  description = "Override name for the ALB scale-down autoscaling policy. Defaults to `${local.name}-alb-scale-down-policy`."
  default     = null
  type        = string
}
