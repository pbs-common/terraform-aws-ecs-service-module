# ECS Service with HTTPS Host-Header Redirects Example

This example demonstrates how to use the `extra_https_listener_rules` and `extra_http_listener_rules` variables to add host-header based redirect rules to your ECS service load balancer.

## Overview

When you need to migrate domains, consolidate subdomains, or redirect legacy URLs to a new service, the extra listener rules feature allows you to configure these redirects directly within the module instead of managing separate `aws_lb_listener_rule` resources.

## Use Cases

- **Domain Migration**: Redirect traffic from an old domain to a new primary domain with a 301 permanent redirect
- **Subdomain Consolidation**: Consolidate multiple subdomains to a single service domain
- **Legacy URL Support**: Maintain backward compatibility by redirecting old URLs to new locations
- **Multi-tenant Routing**: Route different hostnames to the same service with automatic redirects

## Configuration

The key variables are:

### `extra_https_listener_rules`

List of redirect rules for the HTTPS listener. Each rule specifies:

```hcl
extra_https_listener_rules = [
  {
    host_headers         = ["old.example.com", "legacy.example.com"]
    redirect_host        = "example.com"
    redirect_protocol    = "HTTPS"          # optional, default: "HTTPS"
    redirect_status_code = "HTTP_301"       # optional, default: "HTTP_301"
    redirect_path        = "/"              # optional, default: "/"
    redirect_query       = ""               # optional, default: ""
  }
]
```

### `extra_http_listener_rules`

Same structure as HTTPS rules, but applies to HTTP listener if created.

## How It Works

1. **Priority Assignment**: Listener rules are assigned priorities automatically after the standard application rules
2. **Host-Header Matching**: If an incoming request matches one of the specified hostnames, the redirect rule is applied
3. **Redirect Response**: The ALB responds with the specified status code (default: 301) redirecting to the target hostname
4. **Protocol Flexibility**: You can redirect HTTP to HTTPS, HTTP to HTTP, HTTPS to HTTPS, etc.

## Redirect Status Codes

- `HTTP_301`: Permanent redirect (recommended for most migrations)
- `HTTP_302`: Temporary redirect
- `HTTP_303`: See Other (used for POST-to-GET redirects)
- `HTTP_307`: Temporary (preserves HTTP method)
- `HTTP_308`: Permanent (preserves HTTP method)

## Module Outputs

Access the created redirect rules through module outputs:

```hcl
# HTTPS listener ARN
https_listener_arn = module.ecs_service.https_listener_arn

# Extra HTTPS redirect rule ARNs
extra_https_rule_arns = module.ecs_service.extra_https_listener_rule_arns

# Extra HTTP redirect rule ARNs  
extra_http_rule_arns = module.ecs_service.extra_http_listener_rule_arns
```

You can use these ARNs to:
- Add additional listener rules programmatically
- Reference in other Terraform resources
- Monitor and manage rules in AWS console

## Priority Handling

Listener rule priorities are automatically calculated to avoid conflicts:

1. Application rules: `route_priority` to `route_priority + application_rule_count - 1` (default: 10-11)
2. Extra rules: `route_priority + application_rule_count` onwards (default: 12+)

This ensures no conflicts between default routing and redirect rules. Rules are evaluated in priority order (lowest first).

## Example Variables

To run this example, create a `terraform.tfvars` file:

```hcl
environment = "sharedtools"
product     = "example-app"
owner       = "platform-team"
organization = "example"
hosted_zone = "example.com"
```

Then apply:

```bash
terraform init
terraform plan
terraform apply
```

## Requirements

- Terraform >= 1.13.0
- AWS provider >= 6.0.0
- An existing ECS cluster or the module will create one
- A Route53 hosted zone matching your domain

## Notes

- These rules only apply to **Application Load Balancers (ALBs)**, not Network Load Balancers (NLBs)
- HTTPS rules require the HTTPS listener to be enabled (`create_https_listeners = true`)
- HTTP rules only apply if an HTTP listener is created (`only_create_http_listener = true`)
- Multiple host headers in one rule are matched with OR logic (any matching header triggers the redirect)
- Query strings in redirects: Set `redirect_query = "?new=param"` to append query strings, or leave empty to remove them
