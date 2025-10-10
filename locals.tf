locals {
  name                                 = var.name != null ? var.name : var.product
  container_name                       = var.container_name != null ? var.container_name : "app"
  task_family                          = var.task_family != null ? var.task_family : local.name
  load_balancer_name                   = var.load_balancer_name != null ? var.load_balancer_name : local.name
  load_balancer_sg_name                = var.load_balancer_sg_name != null ? var.load_balancer_sg_name : "${local.load_balancer_name}-sg-"
  service_sg_name                      = var.service_sg_name != null ? var.service_sg_name : "${local.name}-service-sg-"
  target_group_name                    = var.target_group_name != null ? var.target_group_name : local.name
  cluster                              = var.cluster != null ? var.cluster : one(module.cluster[*].name)
  task_def_arn                         = var.task_def_arn != null ? var.task_def_arn : one(module.task[*].arn)
  vpc_id                               = var.vpc_id != null ? var.vpc_id : one(data.aws_vpc.vpc[*].id)
  public_service                       = var.public_service != null
  subnets                              = var.subnets != null ? var.subnets : local.internal == true ? local.private_subnets : local.public_subnets
  private_subnets                      = var.private_subnets != null ? var.private_subnets : data.aws_subnets.private_subnets[0].ids
  public_subnets                       = var.public_subnets != null ? var.public_subnets : data.aws_subnets.public_subnets[0].ids
  lookup_hosted_zone                   = local.app_dns_record_count > 0
  lookup_primary_acm_wildcard_cert     = local.lookup_hosted_zone && local.public_service && var.acm_arn == null
  acm_arn                              = var.acm_arn != null ? var.acm_arn : local.lookup_primary_acm_wildcard_cert ? one(data.aws_acm_certificate.primary_acm_wildcard_cert[*].arn) : null
  null_safe_hosted_zone                = var.hosted_zone == null ? "" : var.hosted_zone
  hosted_zone_id                       = local.lookup_hosted_zone ? one(data.aws_route53_zone.hosted_zone[*].zone_id) : null
  internal                             = var.internal != null ? var.internal : var.is_hosted_zone_private
  cnames                               = var.cnames != null ? var.cnames : [local.name]
  aliases                              = var.aliases != null ? var.aliases : ["${local.name}.${local.null_safe_hosted_zone}"]
  app_dns_record_count                 = local.create_lb ? length(local.cnames) : 0
  domain_name                          = !local.create_lb ? null : local.app_dns_record_count == 0 ? one(aws_lb.lb[*].dns_name) : one(aws_route53_record.app[*].fqdn)
  create_http_listeners                = local.create_lb && var.load_balancer_type == "application"
  create_https_listeners               = local.create_lb && var.load_balancer_type == "application" && !var.is_hosted_zone_private
  only_create_http_listener            = local.create_http_listeners && !local.create_https_listeners
  create_nlb                           = local.create_lb && var.load_balancer_type == "network"
  create_nlb_listeners                 = local.create_nlb && var.nlb_protocol != "TCP"
  create_nlb_tcp_listeners             = local.create_nlb && var.nlb_protocol == "TCP" && var.tcp_port != null
  nlb_eips                             = local.create_nlb && var.create_attach_eip_to_nlb == true ? local.subnets : []
  http_application_rule_count          = local.only_create_http_listener ? length(local.aliases) : 0
  https_application_rule_count         = local.create_https_listeners ? length(local.aliases) : 0
  create_lb                            = var.create_lb != null
  create_cidr_access_rule              = length(var.restricted_cidr_blocks) > 0
  create_sg_access_rule                = var.restricted_sg != null
  create_nlb_cidr_access_rule          = local.create_nlb && local.create_cidr_access_rule
  create_nlb_sg_access_rule            = local.create_nlb && local.create_sg_access_rule
  create_virtual_node_cidr_access_rule = local.create_cidr_access_rule != null
  create_virtual_node_sg_access_rule   = local.create_sg_access_rule == true
  lb_security_groups                   = local.create_lb ? [one(aws_security_group.lb_sg[*].id)] : null
  container_protocol                   = var.load_balancer_type == "application" ? var.container_protocol : "TCP"
  healthcheck_protocol                 = var.healthcheck_protocol != null ? var.healthcheck_protocol : local.container_protocol
  healthcheck_matcher                  = var.load_balancer_type == "application" ? var.healthcheck_matcher : null
  healthcheck_timeout                  = var.load_balancer_type == "application" ? var.healthcheck_timeout : null
  enable_execute_command               = var.enable_execute_command != null ? var.enable_execute_command : var.environment != "prod"
  desired_count                        = var.min_capacity
  deployment_maximum_percent           = local.desired_count == 1 ? 200 : var.deployment_maximum_percent # This is to avoid a bug where deployments can't happen because we can't have 1.5 tasks for a service
  create_cloudmap_service              = var.namespace_id != null
  cloudmap_service_id                  = local.create_cloudmap_service ? one(aws_service_discovery_service.service[*].id) : null
  platform_version                     = var.platform_version != null ? var.platform_version : var.launch_type == "FARGATE" ? "LATEST" : null

  creator = "terraform"

  application_signals_envs = var.enable_application_signals == false ? [] : [
    {
      "name" : "OTEL_RESOURCE_ATTRIBUTES",
      "value" : "service.name=${var.product},deployment.environment=${var.environment}"
    },
    {
      "name" : "PYTHONPATH",
      "value" : var.pythonpath
    },
    {
      "name" : "OTEL_EXPORTER_OTLP_PROTOCOL",
      "value" : "http/protobuf"
    },
    {
      "name" : "OTEL_TRACES_SAMPLER",
      "value" : "xray"
    },
    {
      "name" : "OTEL_TRACES_SAMPLER_ARG",
      "value" : "endpoint=http://localhost:2000"
    },
    {
      "name" : "OTEL_LOGS_EXPORTER",
      "value" : "none"
    },
    {
      "name" : "OTEL_PYTHON_DISTRO",
      "value" : "aws_distro"
    },
    {
      "name" : "OTEL_PYTHON_CONFIGURATOR",
      "value" : "aws_configurator"
    },
    {
      "name" : "OTEL_EXPORTER_OTLP_TRACES_ENDPOINT",
      "value" : "http://localhost:4316/v1/traces"
    },
    {
      "name" : "OTEL_AWS_APPLICATION_SIGNALS_EXPORTER_ENDPOINT",
      "value" : "http://localhost:4316/v1/metrics"
    },
    {
      "name" : "OTEL_METRICS_EXPORTER",
      "value" : "none"
    },
    {
      "name" : "OTEL_AWS_APPLICATION_SIGNALS_ENABLED",
      "value" : "true"
    }
  ]

  # setunion() cannot use empty sets 
  env_vars = var.enable_application_signals == false ? var.env_vars : var.env_vars == null || length(var.env_vars) == 0 ? local.application_signals_envs : setunion(
    local.application_signals_envs,
    var.env_vars
  )

  defaulted_tags = merge(
    var.tags,
    {
      Name                                      = local.name
      "${var.organization}:billing:product"     = var.product
      "${var.organization}:billing:environment" = var.environment
      "${var.organization}:billing:owner"       = var.owner
      creator                                   = local.creator
      repo                                      = var.repo
    }
  )

  tags = merge({ for k, v in local.defaulted_tags : k => v if lookup(data.aws_default_tags.common_tags.tags, k, "") != v })
}

data "aws_default_tags" "common_tags" {}
