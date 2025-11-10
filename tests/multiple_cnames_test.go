package test

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"os"
	"testing"
)

func TestMultipleCNAMEs(t *testing.T) {
	privateHostedZone := os.Getenv("TF_VAR_hosted_zone")

	if privateHostedZone == "" {
		t.Fatal("TF_VAR_hosted_zone must be set to run tests. e.g. 'export TF_VAR_hosted_zone=example.private'")
		return
	}

	options := &terraform.Options{
		TerraformDir: "../examples/multiple_cnames",
		LockTimeout:  "5m",
		Upgrade:      true,
	}

	terraform.Init(t, options)
	terraform.Apply(t, options)
	defer terraform.Destroy(t, options)

	// Make sure that domain name is still set properly even though multiple CNAMEs are used
	if terraform.Output(t, options, "domain_name") == "" {
		t.Error("Expected non-empty domain_name as an output when providing multiple CNAMEs")
	}
}
