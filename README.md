# PBS TF ECS Service Module

## Installation

### Using the Repo Source

```hcl
github.com/pbs/terraform-aws-ecs-service-module?ref=x.y.z
```

### Alternative Installation Methods

More information can be found on these install methods and more in [the documentation here](./docs/general/install).

## Usage

This module provisions a basic ECS service. Provide the `image_repo` and `image_tag` corresponding to the Docker image you would like to run, and everything from the ECS task definition to the DNS for the load balancer will be provisioned so that you can access your application.

To make the service provisioned here private, set `public_service` to `false`. This will set up a DNS entry in a private hosted zone, and adjust the load balancer associated with the service such that it is an internal load balancer.

To switch the kind of load balancer used from an application load balancer to a network load balancer, set `load_balancer_type` to `network`.

To run an ECS service on ARM architecture, set `runtime_platform` accordingly. The `cpu_architecture` object property being set to `ARM64` is what adjusts the task definition such that the tasks run on Graviton hardware for Fargate tasks.

Integrate this module like so:

```hcl
module "service" {
  source = "github.com/pbs/terraform-aws-ecs-service-module?ref=x.y.z"

  # Required
  hosted_zone = "example.com"

  # Tagging Parameters
  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo

  # Optional
  image_repo = "nginx"
  image_tag = "latest"
}
```

### ECS Cluster

This module will create an ECS cluster if one is not provided. If you would like to use an existing ECS cluster, provide the `cluster` variable.

```hcl
module "service" {
  source = "github.com/pbs/terraform-aws-ecs-service-module?ref=x.y.z"

  # Required
  hosted_zone = "example.com"

  # Tagging Parameters
  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo

  # Optional
  cluster = "main"
}
```

> :warning: It is not advised to use the default of the automatically created cluster from this module in production, as collocation of services on the same cluster can lead to improved resource utilization, cost savings, reduced complexity and nicer CloudWatch dashboards.
> How much of this applies to you is dependent on your cluster configuration and use-case, however.
> Feel free to use the cluster provisioned by this module when starting out to reduce the friction of getting started, but consider moving to a dedicated cluster as soon as convenient.

## Adding This Version of the Module

If this repo is added as a subtree, then the version of the module should be close to the version shown here:

`x.y.z`

Note, however that subtrees can be altered as desired within repositories.

Further documentation on usage can be found [here](./docs).

Below is automatically generated documentation on this Terraform module using [terraform-docs][terraform-docs]

---

[terraform-docs]: https://github.com/terraform-docs/terraform-docs

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.16.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster"></a> [cluster](#module\_cluster) | github.com/pbs-common/terraform-aws-ecs-cluster-module | 2.0.0 |
| <a name="module_task"></a> [task](#module\_task) | github.com/pbs-common/terraform-aws-ecs-task-definition-module | 3.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.cpu_autoscaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.memory_autoscaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.requests_count_autoscaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.requests_count_scale_down_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.requests_count_scale_up_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.scale_down_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.scale_up_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.autoscaling_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_metric_alarm.cpu_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_low](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory_low](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.requests_count_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.requests_count_low](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_eip.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_lb.lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.http_forward](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.http_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.nlb_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.http_application_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_listener_rule.https_application_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.lb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.service_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.lb_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.lb_to_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nlb_service_access_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nlb_service_access_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.service_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.user_to_lb_http_cidrs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.user_to_lb_http_sgs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.user_to_lb_https_cidrs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.user_to_lb_https_sgs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.user_to_nlb_cidrs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.user_to_nlb_sgs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.user_to_virtual_node_access_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.user_to_virtual_node_access_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_service_discovery_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [aws_acm_certificate.primary_acm_wildcard_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_default_tags.common_tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_route53_zone.hosted_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_subnets.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (sharedtools, dev, staging, qa, prod) | `string` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | Organization using this module. Used to prefix tags so that they are easily identified as being from your organization | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Tag used to group resources according to product | `string` | n/a | yes |
| <a name="input_product"></a> [product](#input\_product) | Tag used to group resources according to product | `string` | n/a | yes |
| <a name="input_repo"></a> [repo](#input\_repo) | Tag used to point to the repo using this module | `string` | n/a | yes |
| <a name="input_acm_arn"></a> [acm\_arn](#input\_acm\_arn) | ARN of the ACM certificate to use for the service. If null, one will be guessed based on the primary hosted zone of the service. | `string` | `null` | no |
| <a name="input_alb_ssl_policy"></a> [alb\_ssl\_policy](#input\_alb\_ssl\_policy) | SSL policy to use for an Application Load Balancer application. | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| <a name="input_aliases"></a> [aliases](#input\_aliases) | CNAME(s) that are allowed to be used for this service. Default is `product`.`hosted_zone`. e.g. [product.example.com] --> [product.example.com] | `list(string)` | `null` | no |
| <a name="input_alpn_policy"></a> [alpn\_policy](#input\_alpn\_policy) | Name of the Application-Layer Protocol Negotiation (ALPN) policy. Can be set if protocol is TLS. Valid values are HTTP1Only, HTTP2Only, HTTP2Optional, HTTP2Preferred, and None. | `string` | `"HTTP2Preferred"` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign public IP to the service | `bool` | `true` | no |
| <a name="input_awslogs_driver_mode"></a> [awslogs\_driver\_mode](#input\_awslogs\_driver\_mode) | (optional) awslogs driver mode. Set this to `blocking` if you would rather have an outage than lose logs. | `string` | `"non-blocking"` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Name of the ECS Cluster this service runs in. If null, one will be created based on the product | `string` | `null` | no |
| <a name="input_cluster_ec2_backed"></a> [cluster\_ec2\_backed](#input\_cluster\_ec2\_backed) | Whether or not to provision an autoscaled EC2 fleet to back the cluster | `bool` | `false` | no |
| <a name="input_cluster_instance_type"></a> [cluster\_instance\_type](#input\_cluster\_instance\_type) | Instance type to use for EC2 backed cluster | `string` | `"m7a.xlarge"` | no |
| <a name="input_cluster_launch_template_version"></a> [cluster\_launch\_template\_version](#input\_cluster\_launch\_template\_version) | Version of the launch template to use | `string` | `"$Latest"` | no |
| <a name="input_cluster_max_instance_lifetime"></a> [cluster\_max\_instance\_lifetime](#input\_cluster\_max\_instance\_lifetime) | Maximum lifetime for an instance in the autoscaling group | `number` | `604800` | no |
| <a name="input_cluster_max_size"></a> [cluster\_max\_size](#input\_cluster\_max\_size) | Maximum size for the autoscaling group to scale out to for the cluster | `number` | `25` | no |
| <a name="input_cluster_maximum_scaling_step_size"></a> [cluster\_maximum\_scaling\_step\_size](#input\_cluster\_maximum\_scaling\_step\_size) | Capacity provider maximum scaling step size | `number` | `10` | no |
| <a name="input_cluster_min_size"></a> [cluster\_min\_size](#input\_cluster\_min\_size) | Minimum size for the autoscaling group to scale out to for the cluster | `number` | `3` | no |
| <a name="input_cluster_minimum_scaling_step_size"></a> [cluster\_minimum\_scaling\_step\_size](#input\_cluster\_minimum\_scaling\_step\_size) | Capacity provider maximum scaling step size | `number` | `1` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster | `string` | `null` | no |
| <a name="input_cluster_protect_from_scale_in"></a> [cluster\_protect\_from\_scale\_in](#input\_cluster\_protect\_from\_scale\_in) | Allow ECS to protect instances running tasks from being terminated while tasks are running on them. Must be false when destroying cluster | `bool` | `true` | no |
| <a name="input_cluster_role_policy_json"></a> [cluster\_role\_policy\_json](#input\_cluster\_role\_policy\_json) | (optional) IAM policy to attach to role used for the instance profile of instances in this cluster | `string` | `null` | no |
| <a name="input_cluster_target_capacity"></a> [cluster\_target\_capacity](#input\_cluster\_target\_capacity) | Capacity provider target capacity | `number` | `75` | no |
| <a name="input_cnames"></a> [cnames](#input\_cnames) | CNAME(s) that are going to be created for this service in the hosted\_zone. This can be set to [] to avoid creating a CNAME for the app. This can be useful for CDNs. Default is `product`. e.g. [product] --> [product.example.com] | `list(string)` | `null` | no |
| <a name="input_command"></a> [command](#input\_command) | (optional) command to run in the container as an array. e.g. ["sleep", "10"]. If null, does not set a command in the task definition. | `list(string)` | `null` | no |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | (optional) JSON container definitions for task | `string` | `null` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | (optional) name for the container to have | `string` | `null` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | (optional) port the container is exposing | `number` | `80` | no |
| <a name="input_container_protocol"></a> [container\_protocol](#input\_container\_protocol) | Protocol to use in connection to the container | `string` | `"HTTP"` | no |
| <a name="input_cpu_reservation"></a> [cpu\_reservation](#input\_cpu\_reservation) | (optional) CPU reservation for task | `number` | `256` | no |
| <a name="input_create_attach_eip_to_nlb"></a> [create\_attach\_eip\_to\_nlb](#input\_create\_attach\_eip\_to\_nlb) | Create EIPs for each subnet and attach them to the NLB (public only) | `bool` | `false` | no |
| <a name="input_create_lb"></a> [create\_lb](#input\_create\_lb) | Create load balancer for service. If creating a virtual node, will ignore value. | `bool` | `true` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment | `number` | `150` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment | `number` | `100` | no |
| <a name="input_dns_evaluate_target_health"></a> [dns\_evaluate\_target\_health](#input\_dns\_evaluate\_target\_health) | evaluate health of endpoints by querying DNS records | `bool` | `false` | no |
| <a name="input_efs_mounts"></a> [efs\_mounts](#input\_efs\_mounts) | (optional) efs mount set of objects. Components should include dns\_name, container\_mount\_point, efs\_mount\_point | <pre>set(object({<br/>    file_system_id = string<br/>    efs_path       = string<br/>    container_path = string<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_application_signals"></a> [enable\_application\_signals](#input\_enable\_application\_signals) | (optional) if set to true, will enable CW Application Signals | `bool` | `false` | no |
| <a name="input_enable_circuit_breaker"></a> [enable\_circuit\_breaker](#input\_enable\_circuit\_breaker) | Enables ECS circuit breaker | `bool` | `true` | no |
| <a name="input_enable_circuit_breaker_rollback"></a> [enable\_circuit\_breaker\_rollback](#input\_enable\_circuit\_breaker\_rollback) | Enables ECS circuit breaker rollback | `bool` | `true` | no |
| <a name="input_enable_cross_zone_load_balancing"></a> [enable\_cross\_zone\_load\_balancing](#input\_enable\_cross\_zone\_load\_balancing) | Enable cross-zone load balancing for NLBs. ALB have this enabled by default and cannot be disabled. | `string` | `true` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | Enables `ecs exec`. If null, will enable if not on prod | `bool` | `null` | no |
| <a name="input_entrypoint"></a> [entrypoint](#input\_entrypoint) | (optional) entrypoint to run in the container as an array. e.g. ["sleep", "10"]. If null, does not set an entrypoint in the task definition. | `list(string)` | `null` | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | (optional) environment variables to be passed to the container. By default, only passes SSM\_PATH | `set(map(any))` | `null` | no |
| <a name="input_envoy_tag"></a> [envoy\_tag](#input\_envoy\_tag) | (optional) tag for envoy. Update periodically if using App Mesh. | `string` | `"v1.23.1.0-prod"` | no |
| <a name="input_extra_role_policy_json"></a> [extra\_role\_policy\_json](#input\_extra\_role\_policy\_json) | (optional) Extra IAM policy to attach to role used for this task without replacing defaults | `string` | `null` | no |
| <a name="input_extra_task_execution_role_policy_json"></a> [extra\_task\_execution\_role\_policy\_json](#input\_extra\_task\_execution\_role\_policy\_json) | (optional) Extra IAM policy to attach to task execution role used for this task without replacing defaults | `string` | `null` | no |
| <a name="input_healthcheck_healthy_threshold"></a> [healthcheck\_healthy\_threshold](#input\_healthcheck\_healthy\_threshold) | The number of consecutive health checks successes required before considering an unhealthy target healthy | `number` | `3` | no |
| <a name="input_healthcheck_interval"></a> [healthcheck\_interval](#input\_healthcheck\_interval) | The approximate amount of time, in seconds, between health checks of an individual target | `number` | `10` | no |
| <a name="input_healthcheck_matcher"></a> [healthcheck\_matcher](#input\_healthcheck\_matcher) | The HTTP codes to use when checking for a successful response from a target | `number` | `200` | no |
| <a name="input_healthcheck_path"></a> [healthcheck\_path](#input\_healthcheck\_path) | The destination for the health check request | `string` | `null` | no |
| <a name="input_healthcheck_protocol"></a> [healthcheck\_protocol](#input\_healthcheck\_protocol) | The protocol to use to connect with the target | `string` | `null` | no |
| <a name="input_healthcheck_timeout"></a> [healthcheck\_timeout](#input\_healthcheck\_timeout) | The amount of time, in seconds, during which no response means a failed health check | `number` | `6` | no |
| <a name="input_healthcheck_unhealthy_threshold"></a> [healthcheck\_unhealthy\_threshold](#input\_healthcheck\_unhealthy\_threshold) | The number of consecutive health check failures required before considering the target unhealthy | `number` | `3` | no |
| <a name="input_hosted_zone"></a> [hosted\_zone](#input\_hosted\_zone) | Name of the hosted zone for DNS. e.g. hosted\_zone = example.org --> service.example.org. Based on the is\_hosted\_zone\_private, this is the primary or the private hosted zone. | `string` | `null` | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | HTTP port number. | `number` | `"80"` | no |
| <a name="input_http_redirect"></a> [http\_redirect](#input\_http\_redirect) | Redirect HTTP traffic to HTTPS. If set to false, HTTP traffic will be forwarded to the target groups | `bool` | `true` | no |
| <a name="input_https_port"></a> [https\_port](#input\_https\_port) | HTTPS port number. | `number` | `"443"` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | Idle timeout for the load balancer. If null, will use whatever the default is for the load balancer type. | `number` | `null` | no |
| <a name="input_image_repo"></a> [image\_repo](#input\_image\_repo) | (optional) image repo. e.g. image\_repo = nginx --> nginx:image\_tag | `string` | `"nginx"` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | (optional) tag of the image. e.g. image\_tag = latest --> image\_repo:latest | `string` | `"alpine"` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | Use an internal load balancer. If null, will be internal when the service is private. | `bool` | `null` | no |
| <a name="input_is_hosted_zone_private"></a> [is\_hosted\_zone\_private](#input\_is\_hosted\_zone\_private) | Is the route53 zone private or not. | `bool` | `false` | no |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | The launch type on which to run your service | `string` | `"FARGATE"` | no |
| <a name="input_lb_deregistration_delay"></a> [lb\_deregistration\_delay](#input\_lb\_deregistration\_delay) | (optional) task deregistration delay for the load balancer | `number` | `300` | no |
| <a name="input_load_balancer_name"></a> [load\_balancer\_name](#input\_load\_balancer\_name) | Load balancer name. Will default to product if not defined. | `string` | `null` | no |
| <a name="input_load_balancer_sg_name"></a> [load\_balancer\_sg\_name](#input\_load\_balancer\_sg\_name) | Prefix for the name of the load balancer security group. If null, will use `${local.load_balancer_name}-sg-`. | `string` | `null` | no |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | Type of load balancer to use. application, network or gateway. | `string` | `"application"` | no |
| <a name="input_log_group_class"></a> [log\_group\_class](#input\_log\_group\_class) | (Optional) log class of the log group. Possible values are: STANDARD or INFREQUENT\_ACCESS | `string` | `"INFREQUENT_ACCESS"` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | (optional) name for the log group | `string` | `null` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | The maximum capacity of tasks for this service | `number` | `2` | no |
| <a name="input_memory_reservation"></a> [memory\_reservation](#input\_memory\_reservation) | (optional) memory reservation for task | `number` | `512` | no |
| <a name="input_mesh_name"></a> [mesh\_name](#input\_mesh\_name) | (optional) the name for the App Mesh this task is associated with. If null, ignored | `string` | `null` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | The minimum capacity of tasks for this service | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the service. Will default to product if not defined. | `string` | `null` | no |
| <a name="input_namespace_id"></a> [namespace\_id](#input\_namespace\_id) | Namespace ID. | `string` | `null` | no |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | (optional) network mode for the task | `string` | `"awsvpc"` | no |
| <a name="input_newrelic_secret_arn"></a> [newrelic\_secret\_arn](#input\_newrelic\_secret\_arn) | ARN for AWS Secrets Manager secret of New Relic Insights insert key. | `string` | `null` | no |
| <a name="input_newrelic_secret_name"></a> [newrelic\_secret\_name](#input\_newrelic\_secret\_name) | Name for AWS Secrets Manager secret of New Relic Insights insert key. | `string` | `null` | no |
| <a name="input_nlb_protocol"></a> [nlb\_protocol](#input\_nlb\_protocol) | Protocol for the network load balancer used in this service. Ignored for application load balancers. | `string` | `"TLS"` | no |
| <a name="input_nlb_ssl_policy"></a> [nlb\_ssl\_policy](#input\_nlb\_ssl\_policy) | SSL policy to use for a Network Load Balancer application. | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| <a name="input_platform_version"></a> [platform\_version](#input\_platform\_version) | The platform version on which to run your service | `string` | `"LATEST"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | Private subnets for the service. If null, private subnets will be looked up based on environment tag and will be selected based on public\_service. | `list(string)` | `null` | no |
| <a name="input_propagate_tags"></a> [propagate\_tags](#input\_propagate\_tags) | Specifies whether to propagate the tags from the task definition or the service to the tasks | `string` | `"SERVICE"` | no |
| <a name="input_public_service"></a> [public\_service](#input\_public\_service) | Service should be provisioned in public subnet. Ignored if subnets defined. | `bool` | `false` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | Public subnets for the service. If null, public subnets will be looked up based on environment tag and will be selected based on public\_service. | `list(string)` | `null` | no |
| <a name="input_pythonpath"></a> [pythonpath](#input\_pythonpath) | (optional) PYTHONPATH of the application; required by the cwagent sidecar container | `string` | `":"` | no |
| <a name="input_requests_count_scaling"></a> [requests\_count\_scaling](#input\_requests\_count\_scaling) | Use RequestCountPerTarget CloudWatch metric for scaling | `bool` | `false` | no |
| <a name="input_requires_compatibilities"></a> [requires\_compatibilities](#input\_requires\_compatibilities) | (optional) capabilities that the task requires | `set(string)` | <pre>[<br/>  "FARGATE"<br/>]</pre> | no |
| <a name="input_restricted_cidr_blocks"></a> [restricted\_cidr\_blocks](#input\_restricted\_cidr\_blocks) | CIDR blocks to receive restricted service access. If empty, no CIDRs will be allowed to connect. | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_restricted_sg"></a> [restricted\_sg](#input\_restricted\_sg) | SG to receive restricted service access. If null, no sg will be configured to connect | `string` | `null` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | (optional) log retention in days | `number` | `7` | no |
| <a name="input_role_policy_json"></a> [role\_policy\_json](#input\_role\_policy\_json) | (optional) IAM policy to attach to role used for this task and replace defaults | `string` | `null` | no |
| <a name="input_route_priority"></a> [route\_priority](#input\_route\_priority) | Starting route priority, incremented by each listener rule | `number` | `10` | no |
| <a name="input_runtime_platform"></a> [runtime\_platform](#input\_runtime\_platform) | (optional) Runtime platform for the task. Defaults to LINUX operating system family w/ CPU architecture x86\_64. | <pre>object({<br/>    operating_system_family = optional(string, "LINUX")<br/>    cpu_architecture        = optional(string, "X86_64")<br/>  })</pre> | <pre>{<br/>  "cpu_architecture": "X86_64",<br/>  "operating_system_family": "LINUX"<br/>}</pre> | no |
| <a name="input_scale_down_adjustment"></a> [scale\_down\_adjustment](#input\_scale\_down\_adjustment) | Tasks to add on scale up | `number` | `-1` | no |
| <a name="input_scale_down_cooldown"></a> [scale\_down\_cooldown](#input\_scale\_down\_cooldown) | Scale down cooldown in minutes | `number` | `5` | no |
| <a name="input_scale_down_cpu_threshold"></a> [scale\_down\_cpu\_threshold](#input\_scale\_down\_cpu\_threshold) | Threshold at which CPU utilization triggers a scale down event | `number` | `20` | no |
| <a name="input_scale_down_memory_threshold"></a> [scale\_down\_memory\_threshold](#input\_scale\_down\_memory\_threshold) | Threshold at which Memory utilization triggers a scale down event | `number` | `20` | no |
| <a name="input_scale_down_requests_count_per_target"></a> [scale\_down\_requests\_count\_per\_target](#input\_scale\_down\_requests\_count\_per\_target) | Threshold at which Request count per target triggers a scale down event | `number` | `70` | no |
| <a name="input_scale_up_adjustment"></a> [scale\_up\_adjustment](#input\_scale\_up\_adjustment) | Tasks to add on scale up | `number` | `2` | no |
| <a name="input_scale_up_cooldown"></a> [scale\_up\_cooldown](#input\_scale\_up\_cooldown) | Scale up cooldown in minutes | `number` | `1` | no |
| <a name="input_scale_up_cpu_threshold"></a> [scale\_up\_cpu\_threshold](#input\_scale\_up\_cpu\_threshold) | Threshold at which CPU utilization triggers a scale up event | `number` | `80` | no |
| <a name="input_scale_up_memory_threshold"></a> [scale\_up\_memory\_threshold](#input\_scale\_up\_memory\_threshold) | Threshold at which Memory utilization triggers a scale up event | `number` | `80` | no |
| <a name="input_scale_up_requests_count_per_target"></a> [scale\_up\_requests\_count\_per\_target](#input\_scale\_up\_requests\_count\_per\_target) | Threshold at which Request count per target triggers a scale up event | `number` | `140` | no |
| <a name="input_scaling_approach"></a> [scaling\_approach](#input\_scaling\_approach) | Approach to take with scaling. Valid values are `target_tracking` and `step_scaling` | `string` | `"target_tracking"` | no |
| <a name="input_scaling_evaluation_period"></a> [scaling\_evaluation\_period](#input\_scaling\_evaluation\_period) | Scaling evaluation period in seconds | `number` | `60` | no |
| <a name="input_scaling_evaluation_periods"></a> [scaling\_evaluation\_periods](#input\_scaling\_evaluation\_periods) | Number of periods over which data is compared to the threshold | `number` | `1` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | (optional) secrets to be passed to the container. By default none is passed | <pre>set(object({<br/>    name      = string<br/>    valueFrom = string<br/>  }))</pre> | `[]` | no |
| <a name="input_service_sg_name"></a> [service\_sg\_name](#input\_service\_sg\_name) | Prefix for the name of the service security group. If null, will use `${local.name}-service-sg-`. | `string` | `null` | no |
| <a name="input_ssm_path"></a> [ssm\_path](#input\_ssm\_path) | (optional) path to the ssm parameters you want pulled into your container during execution of the entrypoint | `string` | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnets for the service. If null, private and public subnets will be looked up based on environment tag and one will be selected based on public\_service. | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Extra tags | `map(string)` | `{}` | no |
| <a name="input_target_cpu_utilization"></a> [target\_cpu\_utilization](#input\_target\_cpu\_utilization) | Target CPU utilization for scaling | `number` | `50` | no |
| <a name="input_target_group_name"></a> [target\_group\_name](#input\_target\_group\_name) | Target group name. Will default to product if not defined. | `string` | `null` | no |
| <a name="input_target_memory_utilization"></a> [target\_memory\_utilization](#input\_target\_memory\_utilization) | Target memory utilization for scaling | `number` | `50` | no |
| <a name="input_target_requests_count_per_target"></a> [target\_requests\_count\_per\_target](#input\_target\_requests\_count\_per\_target) | Target requests count per targe for scaling | `number` | `800` | no |
| <a name="input_task_def_arn"></a> [task\_def\_arn](#input\_task\_def\_arn) | Task definition ARN. If null, task will be created with default values, except that image\_repo and image\_tag may be defined. | `string` | `null` | no |
| <a name="input_task_execution_role_policy_json"></a> [task\_execution\_role\_policy\_json](#input\_task\_execution\_role\_policy\_json) | (optional) IAM policy to attach to task execution role used for this task and replace defaults | `string` | `null` | no |
| <a name="input_task_family"></a> [task\_family](#input\_task\_family) | (optional) task family for task. This is effectively the name of the task, without qualification of revision | `string` | `null` | no |
| <a name="input_tcp_port"></a> [tcp\_port](#input\_tcp\_port) | NLB TCP port number. Ignored for application load balancers. | `number` | `null` | no |
| <a name="input_track_latest"></a> [track\_latest](#input\_track\_latest) | (optional) Whether should track latest ACTIVE task definition on AWS or the one created with the resource stored in state. | `bool` | `false` | no |
| <a name="input_use_xray_sidecar"></a> [use\_xray\_sidecar](#input\_use\_xray\_sidecar) | (optional) if set to null, will use the sidecar to trace the task if envoy is used, as that automatically implements tracing configs. | `bool` | `null` | no |
| <a name="input_virtual_gateway"></a> [virtual\_gateway](#input\_virtual\_gateway) | (optional) the name of the virtual gateway associated with this task definition. If null, ignored | `string` | `null` | no |
| <a name="input_virtual_node"></a> [virtual\_node](#input\_virtual\_node) | (optional) the name of the virtual node associated with this task definition. Ignored if virtual\_gateway set. If null, ignored | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID. If null, one will be looked up based on environment tag. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the service |
| <a name="output_cluster"></a> [cluster](#output\_cluster) | Cluster this service is associated with |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | Name of the main container used by this service |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | One domain name that will resolve to this service. Might not be a valid alias. |
| <a name="output_https_listener_arn"></a> [https\_listener\_arn](#output\_https\_listener\_arn) | ARN of the HTTPS listener. Useful when adding extra ACM certificates to the listener. |
| <a name="output_iam_task_role_arn"></a> [iam\_task\_role\_arn](#output\_iam\_task\_role\_arn) | IAM role ARN associated with a task defition, if task defition is created by the ecs service module |
| <a name="output_image_tag"></a> [image\_tag](#output\_image\_tag) | Tag of the image used by this service |
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | Load balancer ARN |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | Load balancer DNS Name |
| <a name="output_lb_sg"></a> [lb\_sg](#output\_lb\_sg) | Load balancer security group |
| <a name="output_lb_zone_id"></a> [lb\_zone\_id](#output\_lb\_zone\_id) | Load balancer Zone Id |
| <a name="output_name"></a> [name](#output\_name) | Name of the service |
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | CloudMap Service ID |
| <a name="output_service_sg"></a> [service\_sg](#output\_service\_sg) | Service security group |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Subnets used by this service |
| <a name="output_task_def_arn"></a> [task\_def\_arn](#output\_task\_def\_arn) | Current task definition ARN used by this service |
| <a name="output_task_family"></a> [task\_family](#output\_task\_family) | Current task family used by this service |
