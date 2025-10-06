package test

import (
	"fmt"
	"os"
	"testing"
	"time"

	httpHelper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func testECSService(t *testing.T, variant string) {
	t.Parallel()

	var primaryHostedZone string
	var privateHostedZone string
	var expectedDomainName string

	expectedName := fmt.Sprintf("example-tf-ecs-service-%s", variant)

	switch variant {
	case "private":
		privateHostedZone = os.Getenv("TF_VAR_hosted_zone")

		if privateHostedZone == "" {
			t.Fatal("TF_VAR_hosted_zone must be set to run tests. e.g. 'export TF_VAR_hosted_zone=example.private'")
		}

		expectedDomainName = fmt.Sprintf("%s.%s", expectedName, privateHostedZone)
	case "no-lb":
	default:
		primaryHostedZone = os.Getenv("TF_VAR_hosted_zone")

		if primaryHostedZone == "" {
			t.Fatal("TF_VAR_hosted_zone must be set to run tests. e.g. 'export TF_VAR_hosted_zone=example.org'")
		}

		expectedDomainName = fmt.Sprintf("%s.%s", expectedName, primaryHostedZone)
	}

	terraformDir := fmt.Sprintf("../examples/%s", variant)

	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		LockTimeout:  "5m",
		Upgrade:      true,
	}

	defer terraform.Destroy(t, terraformOptions)

	expectedLogGroup := fmt.Sprintf("/ecs/%s", expectedName)

	deleteLogGroup(t, expectedLogGroup)

	terraform.Init(t, terraformOptions)

	switch variant {
	case "efs":
		// We need to apply the EFS module first because of the for_each
		// used on efs_sg_ids in the ECS service module.
		terraformTargetEFSOptions := &terraform.Options{
			TerraformDir: terraformDir,
			LockTimeout:  "5m",
			Targets: []string{
				"module.efs",
			},
		}
		terraform.Apply(t, terraformTargetEFSOptions)
	case "sgs":
		// We need to apply the SGs first because of the count on
		// user_to_virtual_node_access_sg
		terraformTargetSGOptions := &terraform.Options{
			TerraformDir: terraformDir,
			LockTimeout:  "5m",
			Targets: []string{
				"aws_security_group.mysql_sg",
				"aws_security_group.redis_sg",
				"aws_security_group.memcached_sg",
				"aws_security_group.ingress_sg",
			},
		}
		terraform.Apply(t, terraformTargetSGOptions)
	case "am":
		// We need to apply the virtual gateway first
		// because of the for_each used on virtual_gateway_ids
		terraformTargetMeshOptions := &terraform.Options{
			TerraformDir: terraformDir,
			LockTimeout:  "5m",
			Targets: []string{
				"module.mesh",
				"module.namespace",
			},
		}
		terraform.Apply(t, terraformTargetMeshOptions)
	}

	terraform.Apply(t, terraformOptions)

	if variant == "am" {
		serviceIDV1 := terraform.Output(t, terraformOptions, "service_id_v1")
		serviceIDV2 := terraform.Output(t, terraformOptions, "service_id_v2")

		// This will run before the destroy because
		// defers are LIFO
		defer deregisterService(serviceIDV1)
		defer deregisterService(serviceIDV2)
	}

	if variant != "no-lb" {
		domainName := terraform.Output(t, terraformOptions, "domain_name")

		assert.Equal(t, expectedDomainName, domainName)

		if variant != "private" {
			indexURL := fmt.Sprintf("https://%s/", domainName)
			expectedIndex, err := getFileAsString("nginx-index.html")

			if err != nil {
				t.Fatal(err)
			}

			httpHelper.HttpGetWithRetry(t, indexURL, nil, 200, expectedIndex, 25, 1*time.Minute)

			if variant == "am" {
				terraformSplitOptions := &terraform.Options{
					TerraformDir: terraformDir,
					LockTimeout:  "5m",
					Vars: map[string]interface{}{
						"v1_weight": "50",
						"v2_weight": "50",
					},
				}
				terraform.Apply(t, terraformSplitOptions)
				httpHelper.HttpGetWithRetry(t, indexURL, nil, 200, expectedIndex, 25, 1*time.Minute)
				terraformV2Options := &terraform.Options{
					TerraformDir: terraformDir,
					LockTimeout:  "5m",
					Vars: map[string]interface{}{
						"v1_weight": "0",
						"v2_weight": "100",
					},
				}
				terraform.Apply(t, terraformV2Options)
				httpHelper.HttpGetWithRetry(t, indexURL, nil, 200, expectedIndex, 25, 1*time.Minute)
			}
		}
	}
}
