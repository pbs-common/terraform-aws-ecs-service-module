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

## Adding This Version of the Module

If this repo is added as a subtree, then the version of the module should be close to the version shown here:

`x.y.z`

Note, however that subtrees can be altered as desired within repositories.

Further documentation on usage can be found [here](./docs).

Below is automatically generated documentation on this Terraform module using [terraform-docs][terraform-docs]

---

[terraform-docs]: https://github.com/terraform-docs/terraform-docs
