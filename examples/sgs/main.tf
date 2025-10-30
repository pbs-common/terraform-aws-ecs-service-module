resource "aws_security_group" "mysql_sg" {
  description = "Controls access to ${var.product} mysql resources"
  vpc_id      = data.aws_vpc.vpc.id
  name_prefix = "${var.product}-sg-"

  tags = {
    application = var.product
    environment = var.environment
    creator     = "terraform"
  }
}

module "mysql_egress" {
  source = "github.com/pbs/terraform-aws-sg-rule-module?ref=0.0.1"

  description = "Allow all traffic out"

  type              = "egress"
  security_group_id = aws_security_group.mysql_sg.id


  port               = 0
  protocol           = "-1"
  source_cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "redis_sg" {
  description = "Controls access to ${var.product} redis resources"
  vpc_id      = data.aws_vpc.vpc.id
  name_prefix = "${var.product}-sg-"

  tags = {
    application = var.product
    environment = var.environment
    creator     = "terraform"
  }
}

module "redis_egress" {
  source = "github.com/pbs/terraform-aws-sg-rule-module?ref=0.0.1"

  description = "Allow all traffic out"

  type              = "egress"
  security_group_id = aws_security_group.redis_sg.id


  port               = 0
  protocol           = "-1"
  source_cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "memcached_sg" {
  description = "Controls access to ${var.product} memcached resources"
  vpc_id      = data.aws_vpc.vpc.id
  name_prefix = "${var.product}-sg-"

  tags = {
    application = var.product
    environment = var.environment
    creator     = "terraform"
  }
}

module "memcached_egress" {
  source = "github.com/pbs/terraform-aws-sg-rule-module?ref=0.0.1"

  description = "Allow all traffic out"

  type              = "egress"
  security_group_id = aws_security_group.memcached_sg.id


  port               = 0
  protocol           = "-1"
  source_cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "ingress_sg" {
  description = "Controls access to ${var.product} ingress resources"
  vpc_id      = data.aws_vpc.vpc.id
  name_prefix = "${var.product}-sg-"

  tags = {
    application = var.product
    environment = var.environment
    creator     = "terraform"
  }
}
module "service" {
  source = "../.."

  hosted_zone = var.hosted_zone

  restricted_sg = aws_security_group.ingress_sg.id

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}

module "ecs_to_mysql" {
  source = "github.com/pbs/terraform-aws-sg-rule-module?ref=0.0.1"

  security_group_id = aws_security_group.mysql_sg.id

  description = "Allow service ${module.service.name} to access MySQL"

  port                     = 3306
  source_security_group_id = module.service.service_sg
}

module "ecs_to_redis" {
  source = "github.com/pbs/terraform-aws-sg-rule-module?ref=0.0.1"

  security_group_id = aws_security_group.redis_sg.id

  description = "Allow service ${module.service.name} to access Redis"

  port                     = 6379
  source_security_group_id = module.service.service_sg
}

module "ecs_to_memcached_sg" {
  source = "github.com/pbs/terraform-aws-sg-rule-module?ref=0.0.1"

  security_group_id = aws_security_group.memcached_sg.id

  description = "Allow service ${module.service.name} to access Memcached"

  port                     = 11211
  source_security_group_id = module.service.service_sg
}
