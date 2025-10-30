output "name" {
  description = "Name of the service"
  value       = local.name
}

output "arn" {
  description = "ARN of the service"
  value       = aws_ecs_service.service.id
}

output "service_id" {
  description = "CloudMap Service ID"
  value       = local.cloudmap_service_id
}

output "service_sg" {
  description = "Service security group"
  value       = aws_security_group.service_sg.id
}

output "domain_name" {
  description = "One domain name that will resolve to this service. Might not be a valid alias."
  value       = local.domain_name
}

output "subnets" {
  description = "Subnets used by this service"
  value       = local.subnets
}

output "task_family" {
  description = "Current task family used by this service"
  value       = local.task_family
}

output "task_def_arn" {
  description = "Current task definition ARN used by this service"
  value       = local.task_def_arn
}

output "container_name" {
  description = "Name of the main container used by this service"
  value       = local.container_name
}

output "cluster" {
  description = "Cluster this service is associated with"
  value       = local.cluster
}

output "image_tag" {
  description = "Tag of the image used by this service"
  value       = var.image_tag
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener. Useful when adding extra ACM certificates to the listener."
  value       = local.create_https_listeners ? one(aws_lb_listener.https[*].arn) : null
}

output "lb_sg" {
  description = "Load balancer security group"
  value       = local.create_lb ? one(aws_security_group.lb_sg[*].id) : null
}

output "lb_arn" {
  description = "Load balancer ARN"
  value       = local.create_lb ? one(aws_lb.lb[*].arn) : null
}

output "lb_dns_name" {
  description = "Load balancer DNS Name"
  value       = local.create_lb ? one(aws_lb.lb[*].dns_name) : null
}

output "lb_zone_id" {
  description = "Load balancer Zone Id"
  value       = local.create_lb ? one(aws_lb.lb[*].zone_id) : null
}

output "iam_task_role_arn" {
  description = "IAM role ARN associated with a task defition, if task defition is created by the ecs service module"
  value       = var.task_def_arn == null ? module.task[0].role_arn : "N/A"
}