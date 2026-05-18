module "efs" {
  source = "github.com/pbs/terraform-aws-efs-module?ref=0.1.0"

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}

module "service" {
  source = "../.."

  hosted_zone = var.hosted_zone

  efs_mounts = [
    {
      file_system_id = module.efs.id
      efs_path       = "/"
      container_path = "/mnt/efs"
    }
  ]

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}

module "ecs_to_efs" {
  source = "github.com/pbs/terraform-aws-sg-rule-module?ref=0.0.1"

  security_group_id = module.efs.sgs[0]

  description = "Allow service ${module.service.name} to access EFS"

  port                     = 2049
  source_security_group_id = module.service.service_sg
}
