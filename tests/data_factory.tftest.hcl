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
  subnets = {
    RZ = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project/providers/Microsoft.Network/virtualNetworks/vnet/subnets/RZ", name = "RZ" }
  }
  private_dns_zone_ids = {}
  key_vault = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project/providers/Microsoft.KeyVault/vaults/kv-project"
  }
  env               = "Dev"
  userDefinedString = "test"
  location          = "canadacentral"
  tags              = { environment = "test" }
}

run "naming_convention" {
  command = plan

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "SystemAssigned" }
    }
  }

  assert {
    condition     = azurerm_data_factory.df.name == "dev-test-df"
    error_message = "Name must follow {env4}-{userDefinedString7}-df convention"
  }
}

run "default_values" {
  command = plan

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "SystemAssigned" }
    }
  }

  assert {
    condition     = azurerm_data_factory.df.managed_virtual_network_enabled == true
    error_message = "managed_virtual_network_enabled must default to true"
  }
  assert {
    condition     = azurerm_data_factory.df.public_network_enabled == false
    error_message = "public_network_enabled must default to false"
  }
  assert {
    condition     = azurerm_data_factory.df.identity[0].identity_ids == null
    error_message = "identity_ids must be null when type is SystemAssigned and no override is given"
  }
}

run "custom_name_override" {
  command = plan

  variables {
    data_factory = {
      resource_group = "Project"
      name           = "my-existing-df"
      identity       = { type = "SystemAssigned" }
    }
  }

  assert {
    condition     = azurerm_data_factory.df.name == "my-existing-df"
    error_message = "data_factory.name override must be applied"
  }
}

run "github_configuration_with_git_url" {
  command = plan

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "SystemAssigned" }
      github_configuration = {
        account_name       = "example-account"
        branch_name        = "main"
        git_url            = "https://github.mydomain.com"
        repository_name    = "example-repo"
        root_folder        = "/"
        publishing_enabled = true
      }
    }
  }

  assert {
    condition     = azurerm_data_factory.df.github_configuration[0].git_url == "https://github.mydomain.com"
    error_message = "github_configuration.git_url must be wired through"
  }
}

run "github_configuration_no_git_url" {
  command = plan

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "SystemAssigned" }
      github_configuration = {
        account_name       = "example-account"
        branch_name        = "main"
        repository_name    = "example-repo"
        root_folder        = "/"
        publishing_enabled = true
      }
    }
  }

  assert {
    condition     = azurerm_data_factory.df.github_configuration[0].git_url == null
    error_message = "github_configuration.git_url must default to null when omitted (legacy tfvars)"
  }
}

run "vsts_configuration" {
  command = plan

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "SystemAssigned" }
      vsts_configuration = {
        account_name       = "example-vsts-account"
        branch_name        = "main"
        project_name       = "example-project"
        repository_name    = "example-repo"
        root_folder        = "/"
        tenant_id          = "00000000-0000-0000-0000-000000000000"
        publishing_enabled = true
      }
    }
  }

  assert {
    condition     = azurerm_data_factory.df.vsts_configuration[0].project_name == "example-project"
    error_message = "vsts_configuration.project_name must be wired through"
  }
}

run "identity_explicit_override" {
  command = plan

  variables {
    data_factory = {
      resource_group = "Project"
      identity = {
        type         = "UserAssigned"
        identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project/providers/Microsoft.ManagedIdentity/userAssignedIdentities/existing"]
      }
    }
  }

  assert {
    condition     = tolist(azurerm_data_factory.df.identity[0].identity_ids)[0] == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project/providers/Microsoft.ManagedIdentity/userAssignedIdentities/existing"
    error_message = "Explicit identity.identity_ids override must take priority over the module-created UAMI"
  }
}

run "identity_user_assigned_generated" {
  # command=apply: identity_ids[0] compares against azurerm_user_assigned_identity.ui[0].id,
  # which is Computed and unknown until apply (see references/testing.md "Unknown condition value").
  command = apply

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "UserAssigned" }
      user_assigned_identity = {
        name = "example-uami"
      }
    }
  }

  override_resource {
    target = azurerm_user_assigned_identity.ui[0]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project/providers/Microsoft.ManagedIdentity/userAssignedIdentities/example-uami"
    }
  }

  override_resource {
    target = azurerm_data_factory.df
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project/providers/Microsoft.DataFactory/factories/dev-test-df"
    }
  }

  assert {
    condition     = tolist(azurerm_data_factory.df.identity[0].identity_ids)[0] == azurerm_user_assigned_identity.ui[0].id
    error_message = "identity_ids must fall back to the module-created UAMI when no override is given"
  }
}

run "identity_combined_system_and_user_assigned" {
  # command=apply: same Computed-id reason as identity_user_assigned_generated above.
  command = apply

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "SystemAssigned, UserAssigned" }
      user_assigned_identity = {
        name = "example-uami"
      }
    }
  }

  override_resource {
    target = azurerm_user_assigned_identity.ui[0]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project/providers/Microsoft.ManagedIdentity/userAssignedIdentities/example-uami"
    }
  }

  override_resource {
    target = azurerm_data_factory.df
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project/providers/Microsoft.DataFactory/factories/dev-test-df"
    }
  }

  assert {
    condition     = tolist(azurerm_data_factory.df.identity[0].identity_ids)[0] == azurerm_user_assigned_identity.ui[0].id
    error_message = "identity_ids must be set when type is the combined 'SystemAssigned, UserAssigned' value"
  }
}

run "user_assigned_identity_new_args" {
  # command=apply: tags is Optional+Computed on this resource, so its value stays
  # unknown/mocked under command=plan (see references/testing.md "Unknown condition value").
  command = apply

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "UserAssigned" }
      user_assigned_identity = {
        name            = "example-uami"
        isolation_scope = "Regional"
        tags            = { owner = "team-a" }
      }
    }
  }

  override_resource {
    target = azurerm_user_assigned_identity.ui[0]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project/providers/Microsoft.ManagedIdentity/userAssignedIdentities/example-uami"
    }
  }

  override_resource {
    target = azurerm_data_factory.df
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project/providers/Microsoft.DataFactory/factories/dev-test-df"
    }
  }

  assert {
    condition     = azurerm_user_assigned_identity.ui[0].isolation_scope == "Regional"
    error_message = "user_assigned_identity.isolation_scope must be wired through"
  }
  assert {
    condition     = azurerm_user_assigned_identity.ui[0].tags["owner"] == "team-a"
    error_message = "user_assigned_identity.tags override must be wired through"
  }
}

run "user_assigned_identity_tags_default_to_module_tags" {
  # command=apply: same Optional+Computed tags reason as user_assigned_identity_new_args above.
  command = apply

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "UserAssigned" }
      user_assigned_identity = {
        name = "example-uami"
      }
    }
  }

  override_resource {
    target = azurerm_user_assigned_identity.ui[0]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project/providers/Microsoft.ManagedIdentity/userAssignedIdentities/example-uami"
    }
  }

  override_resource {
    target = azurerm_data_factory.df
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project/providers/Microsoft.DataFactory/factories/dev-test-df"
    }
  }

  assert {
    condition     = azurerm_user_assigned_identity.ui[0].tags["environment"] == "test"
    error_message = "user_assigned_identity.tags must default to var.tags"
  }
}

run "user_managed_identity_credential" {
  command = plan

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "UserAssigned" }
      user_assigned_identity = {
        name = "example-uami"
      }
      user_managed_identity = {
        description = "Short description of this credential"
        annotations = ["example", "example2"]
      }
    }
  }

  assert {
    condition     = length(azurerm_data_factory_credential_user_managed_identity.mi[0].annotations) == 2
    error_message = "user_managed_identity.annotations must be wired through"
  }
}

run "user_managed_identity_no_annotations" {
  command = plan

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "UserAssigned" }
      user_assigned_identity = {
        name = "example-uami"
      }
      user_managed_identity = {
        description = "Short description of this credential"
      }
    }
  }

  assert {
    condition     = azurerm_data_factory_credential_user_managed_identity.mi[0].annotations == null
    error_message = "user_managed_identity.annotations must default to null (not error) when omitted"
  }
}

run "service_principal_no_annotations" {
  command = plan

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "SystemAssigned" }
      service_principal = {
        description = "example-service-principle-description"
      }
    }
  }

  assert {
    condition     = azurerm_data_factory_credential_service_principal.spn[0].annotations == null
    error_message = "service_principal.annotations must default to null (not error) when omitted"
  }
}

run "service_principal_name_override" {
  command = plan

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "SystemAssigned" }
      service_principal = {
        name        = "existing-spn"
        description = "example-service-principle-description"
        annotations = ["1", "2"]
      }
    }
  }

  assert {
    condition     = azurerm_data_factory_credential_service_principal.spn[0].name == "existing-spn"
    error_message = "service_principal.name override must be applied"
  }
}

run "key_vault_linked_service_defaults" {
  command = plan

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "SystemAssigned" }
    }
  }

  assert {
    condition     = azurerm_data_factory_linked_service_key_vault.lskv.name == "dev-test-df-kv-linked-service"
    error_message = "key_vault_linked_service name must default to {data-factory-name}-kv-linked-service"
  }
  assert {
    condition     = azurerm_data_factory_linked_service_key_vault.lskv.description == null
    error_message = "key_vault_linked_service.description must default to null"
  }
}

run "key_vault_linked_service_new_args" {
  command = plan

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "SystemAssigned" }
      key_vault_linked_service = {
        name                     = "custom-lskv"
        description              = "Linked service to Key Vault"
        integration_runtime_name = "example-integration-runtime"
        annotations              = ["example"]
        parameters               = { example = "value" }
        additional_properties    = { example = "value" }
      }
    }
  }

  assert {
    condition     = azurerm_data_factory_linked_service_key_vault.lskv.name == "custom-lskv"
    error_message = "key_vault_linked_service.name override must be applied"
  }
  assert {
    condition     = azurerm_data_factory_linked_service_key_vault.lskv.description == "Linked service to Key Vault"
    error_message = "key_vault_linked_service.description must be wired through"
  }
  assert {
    condition     = azurerm_data_factory_linked_service_key_vault.lskv.integration_runtime_name == "example-integration-runtime"
    error_message = "key_vault_linked_service.integration_runtime_name must be wired through"
  }
}

run "secret_defaults" {
  command = plan

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "SystemAssigned" }
    }
  }

  assert {
    condition     = azurerm_key_vault_secret.secret.name == "dev-test-df-secret"
    error_message = "secret name must default to {data-factory-name}-secret"
  }
  assert {
    condition     = azurerm_key_vault_secret.secret.content_type == null
    error_message = "secret.content_type must default to null"
  }
}

run "secret_new_args" {
  command = plan

  variables {
    data_factory = {
      resource_group      = "Project"
      identity            = { type = "SystemAssigned" }
      secret_name         = "custom-secret"
      secret_content_type = "text/plain"
      secret_tags         = { owner = "team-a" }
    }
  }

  assert {
    condition     = azurerm_key_vault_secret.secret.name == "custom-secret"
    error_message = "secret_name override must be applied"
  }
  assert {
    condition     = azurerm_key_vault_secret.secret.content_type == "text/plain"
    error_message = "secret_content_type must be wired through"
  }
  assert {
    condition     = azurerm_key_vault_secret.secret.tags["owner"] == "team-a"
    error_message = "secret_tags must be wired through"
  }
}

run "private_endpoint_new_args" {
  command = plan

  variables {
    data_factory = {
      resource_group = "Project"
      identity       = { type = "SystemAssigned" }
      private_endpoint = {
        adf = {
          resource_group                = "Project"
          subnet                        = "RZ"
          subresource_names             = ["dataFactory"]
          custom_network_interface_name = "custom-nic"
          ip_configuration = [
            { name = "example", private_ip_address = "10.0.0.4" }
          ]
        }
      }
    }
  }

  assert {
    condition     = module.private_endpoint["adf"].name == "dev-test-df-adf-pe"
    error_message = "private_endpoint name must follow {data-factory-name}-{key}-pe convention"
  }
}
