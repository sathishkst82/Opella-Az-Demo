package tests

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestVnetModuleCreatesExpectedSubnets(t *testing.T) {
	t.Parallel()

	if os.Getenv("ARM_SUBSCRIPTION_ID") == "" {
		t.Skip("ARM_SUBSCRIPTION_ID is required for Azure integration tests")
	}

	options := &terraform.Options{
		TerraformDir: "fixtures/vnet",
		Vars: map[string]interface{}{
			"location": "eastus",
		},
		NoColor: true,
	}

	defer terraform.Destroy(t, options)
	terraform.InitAndApply(t, options)

	subnetNames := terraform.OutputMap(t, options, "subnet_names")
	subnetIds := terraform.OutputMap(t, options, "subnet_ids")

	assert.Equal(t, "management-subnet", subnetNames["management"])
	assert.Equal(t, "application-subnet", subnetNames["application"])
	assert.NotEmpty(t, subnetIds["management"])
	assert.NotEmpty(t, subnetIds["application"])
}
