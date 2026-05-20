package tests

import (
  "testing"
  "github.com/gruntwork-io/terratest/modules/terraform"
  "github.com/stretchr/testify/assert"
)

func TestDevVnetOutputs(t *testing.T) {
  opts := &terraform.Options{TerraformDir: "../environments/dev", Vars: map[string]interface{}{"ssh_public_key": "ssh-rsa AAAATEST"}}
  terraform.Init(t, opts)
  out := terraform.OutputMap(t, opts, "subnet_ids")
  assert.Equal(t, 5, len(out))
}
