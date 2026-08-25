# test_dependencies.tf
# Self-contained dependency resources, owned entirely by this harness.
#
# Deliberately NOT reusing any shared/production resource group or key vault:
# writing into a shared L1-managed resource usually requires elevated,
# L1-scoped permissions. A dedicated throwaway RG + key vault here needs only
# Contributor + User Access Administrator (for the RBAC role assignment
# below) on the sandbox subscription and can never collide with or affect any
# production resource.
#
# terraform-azurerm-caf-data-factoryV2 does not consume a virtual_network/
# subnet unless a private_endpoint is configured - this harness deliberately
# leaves data_factory.private_endpoint unset (see config/data_factory.tfvars
# header) so no vnet/subnet dependency is created here.

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "live_test" {
  # pr_number suffix keeps two concurrently open PRs against this module
  # from colliding on the same sandbox resource group or key vault name.
  name     = "${var.env}-caf-data-factory-live-test-${var.pr_number}-rg"
  location = var.location

  tags = {
    "pr-number" = var.pr_number
  }
}

locals {
  # terraform-azurerm-caf-data-factoryV2 resolves its resource group by NAME
  # via a resource_groups map lookup (locals.resource_group_name), not a flat
  # object - so this local is a single-key map, not a flat object.
  resource_groups = {
    livetest = {
      name = azurerm_resource_group.live_test.name
    }
  }
}

resource "azurerm_key_vault" "live_test" {
  name                       = "${var.env}${var.pr_number}dfkv"
  location                   = azurerm_resource_group.live_test.location
  resource_group_name        = azurerm_resource_group.live_test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  soft_delete_retention_days = 7
}

# The module under test writes a generated secret (azurerm_key_vault_secret)
# into this key vault - the identity running Terraform needs Secrets Officer
# on it since the vault uses RBAC authorization, not access policies.
resource "azurerm_role_assignment" "live_test_kv_secrets_officer" {
  scope                = azurerm_key_vault.live_test.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

locals {
  # terraform-azurerm-caf-data-factoryV2 expects key_vault.{id} - a flat object.
  key_vault = {
    id = azurerm_key_vault.live_test.id
  }
}
