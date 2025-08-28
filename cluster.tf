module "cluster" {
  count  = var.cluster == null ? 1 : 0
  source = "github.com/pbs/terraform-aws-ecs-cluster-module?ref=1.0.4"

  # Shared variables
  vpc_id  = local.vpc_id
  subnets = local.subnets

  # Cluster variables

  name = var.cluster_name

  ec2_backed = var.cluster_ec2_backed

  instance_type = var.cluster_instance_type

  max_size = var.cluster_max_size
  min_size = var.cluster_min_size

  max_instance_lifetime = var.cluster_max_instance_lifetime

  role_policy_json = var.cluster_role_policy_json

  protect_from_scale_in = var.cluster_protect_from_scale_in

  maximum_scaling_step_size = var.cluster_maximum_scaling_step_size

  minimum_scaling_step_size = var.cluster_minimum_scaling_step_size

  target_capacity = var.cluster_target_capacity

  launch_template_version = var.cluster_launch_template_version

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}
