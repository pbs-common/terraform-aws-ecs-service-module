module "task" {
  count  = var.task_def_arn == null ? 1 : 0
  source = "github.com/pbs-common/terraform-aws-ecs-task-definition-module?ref=3.0.0"

  name = local.name

  image_repo = var.image_repo
  image_tag  = var.image_tag

  command    = var.command
  entrypoint = var.entrypoint

  mesh_name       = var.mesh_name
  virtual_gateway = var.virtual_gateway

  role_policy_json                      = var.role_policy_json
  task_execution_role_policy_json       = var.task_execution_role_policy_json
  extra_role_policy_json                = var.extra_role_policy_json
  extra_task_execution_role_policy_json = var.extra_task_execution_role_policy_json

  service_name   = local.name
  task_family    = local.task_family
  container_name = var.container_name
  container_port = var.container_port
  track_latest   = var.track_latest

  cpu_reservation    = var.cpu_reservation
  memory_reservation = var.memory_reservation

  virtual_node = var.virtual_node

  ssm_path = var.ssm_path
  env_vars = local.env_vars
  secrets  = var.secrets

  efs_mounts = var.efs_mounts

  newrelic_secret_arn  = var.newrelic_secret_arn
  newrelic_secret_name = var.newrelic_secret_name

  use_xray_sidecar = var.use_xray_sidecar

  use_cwagent_sidecar = var.enable_application_signals

  envoy_tag = var.envoy_tag

  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  container_definitions    = var.container_definitions

  runtime_platform = var.runtime_platform

  log_group_name      = var.log_group_name
  log_group_class     = var.log_group_class
  retention_in_days   = var.retention_in_days
  awslogs_driver_mode = var.awslogs_driver_mode

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}
