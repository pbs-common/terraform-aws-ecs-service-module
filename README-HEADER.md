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

### Capacity Provider Strategy (FARGATE / FARGATE_SPOT)

By default the service runs on the `launch_type` given (`FARGATE` unless overridden). To split a service across both `FARGATE` and `FARGATE_SPOT` instead, set `fargate_weight` and/or `fargate_spot_weight` — this switches the service to a `capacity_provider_strategy` and `launch_type` is ignored.

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
  fargate_weight      = 1
  fargate_spot_weight = 3
}
```

The weights above place roughly 1 in 4 tasks on `FARGATE` and the rest on `FARGATE_SPOT`. Either weight may be omitted (or set to `0`) to run entirely on the other capacity provider while still going through `capacity_provider_strategy` rather than `launch_type` — this is the only way to run a service entirely on `FARGATE_SPOT`, since `launch_type` has no Spot value.

`fargate_base` and `fargate_spot_base` set the minimum number of tasks to place on each provider before weights are applied, and both default to `0` if not set. AWS only allows a non-zero base on one capacity provider in the strategy at a time.

FARGATE and FARGATE_SPOT must be associated with a cluster before a service can reference them. When this module creates the cluster (`cluster = null`) and it is not `cluster_ec2_backed`, that association is handled automatically. If you provide your own `cluster`, make sure FARGATE and FARGATE_SPOT are already associated with it. Combining `cluster_ec2_backed = true` with `fargate_weight`/`fargate_spot_weight` on a module-managed cluster is not currently supported and fails a precondition check, because the EC2-backed cluster already manages its own capacity provider association for its ASG.

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

### Step Scaling Options

The step-scaling approaches, `step_scaling` (CPU/memory), `sqs` and `request_count`, share the scale-up inputs below. They are not supported with `requests_count_scaling = true`; use `scaling_approach = "request_count"` instead.

By default every scale-up adds `scale_up_adjustment` tasks, however large the breach. Set `scale_up_steps` to add more tasks for a bigger breach. Bounds are offsets from the threshold in the metric's own units, not percentages: percentage points of CPU or memory for `step_scaling`, messages for `sqs`, and requests for `request_count`. Steps must start at `0`, be contiguous, and leave `upper_bound` unset on the last one. With `request_count` and the default threshold of 140, this adds 1 task up to 50% over the threshold, 2 tasks up to 100% over, and 4 tasks beyond that:

```hcl
scaling_approach       = "request_count"
alb_scale_up_threshold = 140

scale_up_steps = [
  { lower_bound = 0, upper_bound = 70, adjustment = 1 },
  { lower_bound = 70, upper_bound = 140, adjustment = 2 },
  { lower_bound = 140, adjustment = 4 },
]
```

Size adjustments to the service's normal task count: a step that doubles a 2-task service is a modest jump for a 20-task one. However large a step is, the service never grows beyond `max_capacity`.

A service's own metrics only rise once traffic reaches it. To scale up earlier, for instance when an upstream service starts receiving more traffic, add alarms with `additional_scale_up_alarms`. Each one triggers the same scale-up policy as the approach's own scale-up alarms. Any alarm firing scales the service up, so extra alarms can make it scale up earlier but never later. Each alarm takes CloudWatch `metric_queries`, metrics or math expressions, and exactly one of them must set `return_data = true`:

```hcl
additional_scale_up_alarms = [{
  name                = "upstream"
  threshold           = 5000
  evaluation_periods  = 2
  datapoints_to_alarm = 1
  metric_queries = [{
    id          = "upstream_requests"
    return_data = true
    metric = {
      namespace   = "AWS/ApplicationELB"
      metric_name = "RequestCount"
      dimensions = {
        LoadBalancer = "app/upstream-alb/1111111111111111"
        TargetGroup  = "targetgroup/upstream-tg/2222222222222222"
      }
    }
  }]
}]
```

Extra alarms only trigger scale-up; they do not hold back scale-down. During an upstream surge that has not yet reached this service, the service's own metric is still low, and scaling up early lowers it further, so the scale-down alarm can be in ALARM at the same time as the extra alarm. The service then scales up every `scale_up_cooldown` and back down every `scale_down_cooldown` for as long as both alarms fire. To avoid that, make scale-down deliberately slow when using extra alarms: a conservative scale-down threshold, scale-down datapoints to alarm equal to the evaluation periods, and a `scale_down_cooldown` longer than the time the surge takes to reach this service.

## Adding This Version of the Module

If this repo is added as a subtree, then the version of the module should be close to the version shown here:

`x.y.z`

Note, however that subtrees can be altered as desired within repositories.

Further documentation on usage can be found [here](./docs).

Below is automatically generated documentation on this Terraform module using [terraform-docs][terraform-docs]

---

[terraform-docs]: https://github.com/terraform-docs/terraform-docs
