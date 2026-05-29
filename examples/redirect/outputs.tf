output "service_arn" {
  description = "ARN of the ECS service"
  value       = module.ecs_service.arn
}

output "service_name" {
  description = "Name of the ECS service"
  value       = module.ecs_service.name
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.ecs_service.lb_dns_name
}

output "https_listener_arn" {
  description = "HTTPS listener ARN for adding additional rules"
  value       = module.ecs_service.https_listener_arn
}

output "extra_https_redirect_rule_arns" {
  description = "ARNs of the extra HTTPS redirect listener rules created"
  value       = module.ecs_service.extra_https_listener_rule_arns
}

output "extra_http_redirect_rule_arns" {
  description = "ARNs of the extra HTTP redirect listener rules created"
  value       = module.ecs_service.extra_http_listener_rule_arns
}
