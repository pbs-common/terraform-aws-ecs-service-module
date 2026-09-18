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

To make the service provisioned here private, set `lb_scheme` to `"internal"`. This will create an internal load balancer in private subnets. By default, ECS tasks are placed in private subnets regardless of `lb_scheme`. Use `task_subnet_scheme = "public"` to place tasks in public subnets (only respected when `lb_scheme = "public"`).

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

### Security Groups

This module creates a security group for the service's tasks, and another for the load balancer when it creates one. Each service therefore has its own security group rather than sharing one, which keeps the grant to a database or cache scoped to the single service that needs it.

Grant a service access to a resource by adding a rule to *that resource's* security group, sourced from this module's `service_sg` output — see [the sgs example](/examples/sgs).

Both security groups are named with a prefix by default, letting AWS append a unique suffix. Set `use_sg_name_prefix = false` to give them exact names via `load_balancer_sg_name` and `service_sg_name`. That is what allows security groups that already exist under a fixed name to be adopted by this module, since a security group cannot switch between a generated and a fixed name without being replaced.

### Listeners

For an ALB, the HTTPS listener rejects requests by default and forwards only those matched by a listener rule. What happens on the HTTP listener depends on `http_listener_action`:

| `http_listener_action` | HTTP listener behaviour |
|---|---|
| `null` (default) | Redirects to HTTPS, or forwards to the target group when `http_redirect = false`. With no HTTPS listener, rejects by default and serves traffic through listener rules. |
| `redirect` | Redirects to HTTPS. |
| `forward` | Forwards to the target group. |
| `fixed_response` | Rejects by default and serves traffic through listener rules, even when an HTTPS listener also exists. |

`listener_default_status_code` sets what the rejecting default action returns on both listeners (`403` by default).

Listener rules match the service's aliases on the host header, plus any `custom_http_headers`. Set `listener_rule_host_header = false` to match on the custom headers alone — for a service reachable only through a CDN that injects a shared secret header, say, where the host header varies. One rule is then created per listener instead of one per alias, and `custom_http_headers` must be non-empty because an ALB listener rule needs at least one condition.

See [the cdn-only example](/examples/cdn-only) for a service that rejects on both listeners and routes on a CDN header alone.

### SQS Scaling

With `scaling_approach = "sqs"`, the service scales on an SQS queue's metrics. The scale-up and scale-down alarms are configured independently, because a queue-backed worker usually needs asymmetric signals: scale up as soon as work arrives, but scale down only once nothing is still in flight.

`sqs_metric_name` sets the metric for both alarms. Override either side with `sqs_up_metric_name` / `sqs_down_metric_name`, and tune each alarm with the matching `sqs_up_*` / `sqs_down_*` variable for statistic, comparison operator, evaluation periods and datapoints to alarm.

A worker that must not be scaled down while messages are in flight, for instance, scales up on `ApproximateNumberOfMessagesVisible` and down on `ApproximateNumberOfMessagesNotVisible`:

```hcl
scaling_approach = "sqs"
sqs_queue_name   = "my-app-work"

sqs_up_metric_name         = "ApproximateNumberOfMessagesVisible"
sqs_visible_up_threshold   = 100
sqs_up_evaluation_periods  = 2
sqs_up_datapoints_to_alarm = 2

sqs_down_metric_name         = "ApproximateNumberOfMessagesNotVisible"
sqs_visible_down_threshold   = 5
sqs_down_evaluation_periods  = 2
sqs_down_datapoints_to_alarm = 2
```

## Adding This Version of the Module

If this repo is added as a subtree, then the version of the module should be close to the version shown here:

`x.y.z`

Note, however that subtrees can be altered as desired within repositories.

Further documentation on usage can be found [here](./docs).

Below is automatically generated documentation on this Terraform module using [terraform-docs][terraform-docs]

---

[terraform-docs]: https://github.com/terraform-docs/terraform-docs
