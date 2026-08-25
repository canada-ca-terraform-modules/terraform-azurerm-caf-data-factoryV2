# config/data_factory.tfvars
# Representative real-usage fixture for terraform-azurerm-caf-data-factoryV2,
# used by the `live-test` PR check (see ../../.github/workflows/live-test.yml).
#
# This harness deploys into its own throwaway resource group + key vault (see
# test_dependencies.tf) - no shared resource group permissions needed, and no
# risk of colliding with any real resource.
#
# data_factory.private_endpoint is deliberately left UNSET: this module does
# not require a virtual_network/subnet unless a private endpoint is
# configured, and private endpoint wiring is exercised by the
# private_endpoint module's own test suite, not re-tested live here.
#
# identity.type is a plain "UserAssigned" - the real Azure Data Factory API
# rejects azurerm_data_factory_credential_user_managed_identity unless the
# referenced UAMI is actually attached to the factory's own
# identity.identity_ids, which this module wires automatically when the type
# includes "UserAssigned" (see module.tf's identity_ids fallback).

data_factory = {
  resource_group                  = "livetest"
  managed_virtual_network_enabled = true
  public_network_enabled          = true

  identity = {
    type = "UserAssigned"
  }

  service_principal = {
    description = "live-test service principal credential"
    annotations = ["live-test"]
  }

  user_assigned_identity = {
    name            = "livetest-df-uami"
    isolation_scope = "Regional"
    tags = {
      purpose = "module-live-test"
    }
  }

  user_managed_identity = {
    description = "credential linking the user-assigned identity above"
    annotations = ["live-test"]
  }

  key_vault_linked_service = {
    description           = "Key Vault linked service for the live-test"
    annotations           = ["live-test"]
    parameters            = { example = "value" }
    additional_properties = { example = "value" }
  }

  secret_content_type = "text/plain"
}
