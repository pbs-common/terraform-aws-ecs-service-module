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
  description = "Approach to take with scaling. Valid values are `target_tracking`, `step_scaling`, `sqs`, `request_count` and `none`"
  default     = "target_tracking"
  type        = string
  validation {
    condition     = contains(["target_tracking", "step_scaling", "sqs", "request_count", "none"], var.scaling_approach)
    error_message = "Scaling approach must be `target_tracking`, `step_scaling`, `sqs`, `request_count` or `none`."
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

variable "cpu_count_scaling" {
  description = "Use CPU CloudWatch metric for scaling"
  default     = true
  type        = bool
}

variable "memory_count_scaling" {
  description = "Use Memory CloudWatch metric for scaling"
  default     = false
  type        = bool
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
  type        = string
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

variable "http_listener_action" {
  description = <<EOT
(optional) Default action of the HTTP listener. Valid values are `redirect` (to HTTPS), `forward` (to the target group) and `fixed_response`.

When null the action is derived as before: `fixed_response` when there is no HTTPS listener, otherwise `redirect` or `forward` according to `http_redirect`.

Set this to `fixed_response` explicitly to get an HTTP listener that rejects by default *alongside* an HTTPS listener, so both listeners serve traffic only through their listener rules. `redirect` and `forward` still require an HTTPS listener.
EOT
  default     = null
  type        = string
  validation {
    condition     = var.http_listener_action == null || contains(["redirect", "forward", "fixed_response"], coalesce(var.http_listener_action, "redirect"))
    error_message = "The http_listener_action must be `redirect`, `forward` or `fixed_response`."
  }
}

variable "listener_default_status_code" {
  description = "(optional) HTTP status code returned by the default `fixed-response` action of the HTTP and HTTPS listeners. Requests that match no listener rule get this. Set it to match an existing listener you are adopting, since a differing status code is an in-place listener update that briefly changes what unmatched requests receive."
  default     = "403"
  type        = string
  validation {
    condition     = can(regex("^[2-5][0-9][0-9]$", var.listener_default_status_code))
    error_message = "The listener_default_status_code must be a three-digit HTTP status code between 200 and 599."
  }
}

variable "create_http_listener_rules" {
  description = "(optional) Create the application listener rules on the HTTP listener. When null, rules are created whenever the HTTP listener's default action is `fixed_response` (otherwise the listener redirects or forwards everything and rules would be unreachable). Set to false for an HTTP listener that rejects every request."
  default     = null
  type        = bool
}

variable "listener_rule_host_header" {
  description = "(optional) Match the service's aliases with a `host_header` condition on the application listener rules. Set to false to route on `custom_http_headers` alone — for a service reachable only through a CDN that injects a shared secret header, say, where the host header varies. With this false a single rule is created per listener instead of one per alias, and `custom_http_headers` must be non-empty because a listener rule needs at least one condition."
  default     = true
  type        = bool
  validation {
    condition     = var.listener_rule_host_header || length(var.custom_http_headers) > 0
    error_message = "When listener_rule_host_header is false, custom_http_headers must contain at least one header: an ALB listener rule must have at least one condition."
  }
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
  description = "Name of the load balancer security group. Used as a prefix unless `use_sg_name_prefix` is false. If null, will use `$${local.load_balancer_name}-sg-` (prefix) or `$${local.load_balancer_name}-sg` (exact name)."
  default     = null
  type        = string
}

variable "service_sg_name" {
  description = "Name of the service security group. Used as a prefix unless `use_sg_name_prefix` is false. If null, will use `$${local.name}-service-sg-` (prefix) or `$${local.name}-service-sg` (exact name)."
  default     = null
  type        = string
}

variable "use_sg_name_prefix" {
  description = "(optional) Treat `load_balancer_sg_name` and `service_sg_name` as name prefixes, letting AWS append a unique suffix. Set to false to give the security groups those exact names — needed to adopt security groups that already exist under a fixed name, since a security group cannot switch between a generated and a fixed name without being replaced."
  default     = true
  type        = bool
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

variable "sqs_metric_name" {
  description = "CloudWatch metric name to use for SQS-based scaling alarms. Defaults to `ApproximateNumberOfMessagesVisible`. Acts as the fallback for `sqs_up_metric_name` and `sqs_down_metric_name`."
  default     = "ApproximateNumberOfMessagesVisible"
  type        = string
}

# The scale-up and scale-down alarms are configured independently because a queue-backed worker
# usually needs asymmetric signals: scale up on work arriving, but scale down only once nothing is
# still in flight. Every default below reproduces the previous single-metric behaviour.

variable "sqs_up_metric_name" {
  description = "(optional) CloudWatch metric name for the SQS scale-up alarm. Falls back to `sqs_metric_name`."
  default     = null
  type        = string
}

variable "sqs_down_metric_name" {
  description = "(optional) CloudWatch metric name for the SQS scale-down alarm. Falls back to `sqs_metric_name`. Set this to a different metric than the scale-up alarm to avoid scaling down while messages are still in flight — `ApproximateNumberOfMessagesNotVisible` or `ApproximateAgeOfOldestMessage`, for instance."
  default     = null
  type        = string
}

variable "sqs_up_statistic" {
  description = "(optional) Statistic applied to the metric of the SQS scale-up alarm."
  default     = "Sum"
  type        = string
  validation {
    condition     = contains(["Sum", "Average", "Minimum", "Maximum", "SampleCount"], var.sqs_up_statistic)
    error_message = "The sqs_up_statistic must be one of [Sum, Average, Minimum, Maximum, SampleCount]."
  }
}

variable "sqs_down_statistic" {
  description = "(optional) Statistic applied to the metric of the SQS scale-down alarm."
  default     = "Sum"
  type        = string
  validation {
    condition     = contains(["Sum", "Average", "Minimum", "Maximum", "SampleCount"], var.sqs_down_statistic)
    error_message = "The sqs_down_statistic must be one of [Sum, Average, Minimum, Maximum, SampleCount]."
  }
}

variable "sqs_up_comparison_operator" {
  description = "(optional) How the SQS scale-up alarm compares the metric to `sqs_visible_up_threshold`."
  default     = "GreaterThanThreshold"
  type        = string
  validation {
    condition     = contains(["GreaterThanOrEqualToThreshold", "GreaterThanThreshold", "LessThanThreshold", "LessThanOrEqualToThreshold"], var.sqs_up_comparison_operator)
    error_message = "The sqs_up_comparison_operator must be one of [GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold]."
  }
}

variable "sqs_down_comparison_operator" {
  description = "(optional) How the SQS scale-down alarm compares the metric to `sqs_visible_down_threshold`."
  default     = "LessThanThreshold"
  type        = string
  validation {
    condition     = contains(["GreaterThanOrEqualToThreshold", "GreaterThanThreshold", "LessThanThreshold", "LessThanOrEqualToThreshold"], var.sqs_down_comparison_operator)
    error_message = "The sqs_down_comparison_operator must be one of [GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold]."
  }
}

variable "sqs_up_evaluation_periods" {
  description = "(optional) Number of periods the SQS scale-up alarm evaluates."
  default     = 1
  type        = number
}

variable "sqs_down_evaluation_periods" {
  description = "(optional) Number of periods the SQS scale-down alarm evaluates. Raise this to make scale-down deliberately slower than scale-up."
  default     = 1
  type        = number
}

variable "sqs_up_datapoints_to_alarm" {
  description = "(optional) Datapoints within the evaluation periods that must breach before the SQS scale-up alarm fires. Defaults to all of them."
  default     = null
  type        = number
}

variable "sqs_down_datapoints_to_alarm" {
  description = "(optional) Datapoints within the evaluation periods that must breach before the SQS scale-down alarm fires. Defaults to all of them."
  default     = null
  type        = number
}

variable "sqs_period" {
  description = "(optional) Period, in seconds, over which each SQS scaling alarm's metric is aggregated."
  default     = 60
  type        = number
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
  description = "ARN of the ALB used for ALB-based scaling. Required when `scaling_approach` is `request_count` and `create_lb` is false. When `create_lb` is true the module's own ALB is used automatically."
  default     = null
  type        = string
}

variable "alb_target_group_arn" {
  description = "ARN of the ALB target group used for ALB-based scaling. Required when `scaling_approach` is `request_count` and `create_lb` is false. When `create_lb` is true the module's own target group is used automatically."
  default     = null
  type        = string
}

variable "alb_scale_up_threshold" {
  description = "RequestCountPerTarget value that triggers a scale-up event when `scaling_approach` is `request_count`."
  default     = 140
  type        = number
}

variable "alb_scale_down_threshold" {
  description = "RequestCountPerTarget value below which a scale-down event is triggered when `scaling_approach` is `request_count`."
  default     = 70
  type        = number
}

variable "alb_alarm_high_name" {
  description = "Override name for the ALB scale-up CloudWatch alarm. Defaults to `$${local.name}-request-count-high`."
  default     = null
  type        = string
}

variable "alb_alarm_low_name" {
  description = "Override name for the ALB scale-down CloudWatch alarm. Defaults to `$${local.name}-request-count-low`."
  default     = null
  type        = string
}

variable "alb_scale_up_policy_name" {
  description = "Override name for the ALB scale-up autoscaling policy. Defaults to `$${local.name}-request-count-scale-up-policy`."
  default     = null
  type        = string
}

variable "alb_scale_down_policy_name" {
  description = "Override name for the ALB scale-down autoscaling policy. Defaults to `$${local.name}-request-count-scale-down-policy`."
  default     = null
  type        = string
}

variable "extra_acm_arns" {
  description = "List of additional ACM certificate ARNs to attach to the HTTPS and NLB listeners."
  default     = []
  type        = list(string)
}

variable "extra_service_security_group_ids" {
  description = "(optional) List of additional security group IDs to attach to the ECS service tasks, alongside the module-managed service security group."
  default     = []
  type        = list(string)
}

variable "extra_lb_security_group_ids" {
  description = "(optional) List of additional security group IDs to attach to the load balancer, alongside the module-managed load balancer security group. Ignored when no load balancer is created."
  default     = []
  type        = list(string)
}
