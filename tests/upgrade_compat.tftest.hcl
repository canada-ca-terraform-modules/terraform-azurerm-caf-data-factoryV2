# Purpose: catch breaking resource address/argument changes across the
# upgrade — every run below only ever plans (never applies): this module
# chains 4+ cross-resource ARM-ID references (df -> lskv -> spn, df -> ui ->
# mi), well past the 1-2 reference threshold where a mock `apply` + manual
# `override_resource` id-patching stays practical (see references/testing.md
# "Upgrade compatibility test" note in the eslz-module-upgrade skill).
mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id = "00000000-0000-0000-0000-000000000001"
      client_id = "00000000-0000-0000-0000-000000000002"
    }
  }
}
mock_provider "random" {}

variables {
  resource_groups = {
    Project = { name = "rg-project", location = "canadacentral" }
  }
  subnets              = {}
  private_dns_zone_ids = {}
  key_vault = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project/providers/Microsoft.KeyVault/vaults/kv-project"
  }
  env               = "Dev"
  userDefinedString = "test"
  location          = "canadacentral"
  tags              = { environment = "test" }
}

# Step 1: simulate a currently-deployed resource — pre-upgrade tfvars shape only
# (no new args added by this upgrade).
run "baseline_plan" {
  command = plan

  variables {
    data_factory = {
      resource_group                  = "Project"
      managed_virtual_network_enabled = true
      public_network_enabled          = true
      identity                        = { type = "SystemAssigned" }
      global_parameter = {
        param1 = { name = "example_param", type = "String", value = "example_value" }
      }
      service_principal = {
        description = "example-service-principle-description"
        annotations = ["1", "2"]
      }
      user_assigned_identity = {
        name = "example-user-assigned-identity"
      }
      user_managed_identity = {
        description = "Short description of this credential"
        annotations = ["example", "example2"]
      }
    }
  }

  assert {
    condition     = azurerm_data_factory.df.name == "dev-test-df"
    error_message = "Baseline plan: unexpected resource name"
  }
  assert {
    condition     = azurerm_data_factory_credential_service_principal.spn[0].name == "dev-test-df-spn"
    error_message = "Baseline plan: unexpected service principal credential name"
  }
}

# Step 2: plan the upgraded code with the exact same pre-upgrade inputs — resource
# addresses, names and argument values that already existed must be unchanged.
run "upgrade_plan_no_replacement" {
  command = plan

  variables {
    data_factory = {
      resource_group                  = "Project"
      managed_virtual_network_enabled = true
      public_network_enabled          = true
      identity                        = { type = "SystemAssigned" }
      global_parameter = {
        param1 = { name = "example_param", type = "String", value = "example_value" }
      }
      service_principal = {
        description = "example-service-principle-description"
        annotations = ["1", "2"]
      }
      user_assigned_identity = {
        name = "example-user-assigned-identity"
      }
      user_managed_identity = {
        description = "Short description of this credential"
        annotations = ["example", "example2"]
      }
    }
  }

  assert {
    condition     = azurerm_data_factory.df.name == "dev-test-df"
    error_message = "Resource name must be unchanged after upgrade"
  }
  assert {
    condition     = azurerm_data_factory_credential_service_principal.spn[0].name == "dev-test-df-spn"
    error_message = "Service principal credential name must be unchanged after upgrade"
  }
  assert {
    condition     = azurerm_data_factory_linked_service_key_vault.lskv.name == "dev-test-df-kv-linked-service"
    error_message = "Key Vault linked service name must be unchanged after upgrade"
  }
  assert {
    condition     = azurerm_key_vault_secret.secret.name == "dev-test-df-secret"
    error_message = "Key Vault secret name must be unchanged after upgrade"
  }
}

# Step 3: same inputs plus every new argument this upgrade adds — must plan
# additively, with no change to any pre-existing name or address.
run "upgrade_plan_with_new_arguments" {
  command = plan

  variables {
    data_factory = {
      resource_group                  = "Project"
      managed_virtual_network_enabled = true
      public_network_enabled          = true
      identity                        = { type = "SystemAssigned" }
      global_parameter = {
        param1 = { name = "example_param", type = "String", value = "example_value" }
      }
      service_principal = {
        description = "example-service-principle-description"
        annotations = ["1", "2"]
      }
      user_assigned_identity = {
        name            = "example-user-assigned-identity"
        isolation_scope = "Regional"
      }
      user_managed_identity = {
        description = "Short description of this credential"
        annotations = ["example", "example2"]
      }
      secret_content_type = "text/plain"
      key_vault_linked_service = {
        description = "Linked service to Key Vault"
      }
    }
  }

  assert {
    condition     = azurerm_data_factory.df.name == "dev-test-df"
    error_message = "Resource name must be unchanged when new optional arguments are added"
  }
  assert {
    condition     = azurerm_user_assigned_identity.ui[0].isolation_scope == "Regional"
    error_message = "New isolation_scope argument must be set"
  }
  assert {
    condition     = azurerm_key_vault_secret.secret.content_type == "text/plain"
    error_message = "New secret_content_type argument must be set"
  }
}
