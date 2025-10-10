module "mesh" {
  source = "github.com/pbs/terraform-aws-app-mesh-module?ref=0.0.1"

  name = var.product

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}

module "virtual_gateway" {
  source = "github.com/pbs/terraform-aws-virtual-gateway-module?ref=0.0.1"

  mesh_name = module.mesh.id

  primary_hosted_zone = var.hosted_zone

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}

module "virtual_service" {
  source = "github.com/pbs/terraform-aws-virtual-service-module?ref=0.0.1"

  mesh_name = module.mesh.id

  virtual_router_name = module.router.name

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}

resource "aws_appmesh_gateway_route" "gateway_route" {
  name                 = var.product
  mesh_name            = module.mesh.id
  virtual_gateway_name = module.virtual_gateway.name

  spec {
    http_route {
      action {
        target {
          virtual_service {
            virtual_service_name = module.virtual_service.name
          }
        }
      }

      match {
        prefix = "/"
      }
    }
  }

  tags = {
    Name         = var.product
    organization = var.organization
    environment  = var.environment
    product      = var.product
    repo         = var.repo
  }
}

module "router" {
  source    = "github.com/pbs/terraform-aws-virtual-router-module?ref=0.0.1"
  mesh_name = module.mesh.id

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}

resource "aws_appmesh_route" "route" {
  name                = var.product
  mesh_name           = module.mesh.id
  virtual_router_name = module.router.name

  spec {
    http_route {
      match {
        prefix = "/"
      }

      action {
        weighted_target {
          virtual_node = module.service_v1.virtual_node_name
          weight       = var.v1_weight
        }

        weighted_target {
          virtual_node = module.service_v2.virtual_node_name
          weight       = var.v2_weight
        }
      }

      retry_policy {
        http_retry_events = [
          "client-error",
          "gateway-error",
          "server-error",
          "stream-error",
        ]
        max_retries = 3
        tcp_retry_events = [
          "connection-error",
        ]
        per_retry_timeout {
          unit  = "s"
          value = 5
        }
      }

      timeout {
        idle {
          unit  = "s"
          value = 5
        }

        per_request {
          unit  = "s"
          value = 5
        }
      }
    }
  }

  tags = {
    Name         = var.product
    organization = var.organization
    environment  = var.environment
    product      = var.product
    repo         = var.repo
  }
}

module "namespace" {
  source = "github.com/pbs/terraform-aws-namespace-module?ref=0.0.1"

  type = "public"
  name = "example.org"

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}

module "service_v1" {
  source = "../.."

  name = "${var.product}-v1"

  mesh_name    = module.mesh.id
  virtual_node = "ex-service-v1"

  namespace    = var.product
  namespace_id = module.namespace.id

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}

module "service_v2" {
  source = "../.."

  name = "${var.product}-v2"

  mesh_name    = module.mesh.id
  virtual_node = "ex-service-v2"

  namespace    = var.product
  namespace_id = module.namespace.id

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}
