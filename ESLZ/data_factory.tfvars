data_factories = {
  df1 = {
    resource_group                  = "Project"
    key_vault_group                 = "Keyvault"
    managed_virtual_network_enabled = true
    public_network_enabled          = true
    # name = ""  # Optional: Override the auto-generated data factory name (default: {env4}-{userDefinedString7}-df)
    identity = {
      type = "SystemAssigned"
      # New in azurerm >= 5.0: explicit identity_ids override (existing UAMIs not created by this module)
      # identity_ids = ["/subscriptions/.../resourceGroups/.../providers/Microsoft.ManagedIdentity/userAssignedIdentities/example"]
    }
    # github_configuration ={
    #     account_name    = "example-account"
    #     branch_name     = "main"
    #     repository_name = "example-repo"
    #     root_folder     = "/"
    #     publishing_enabled = true
    #     # git_url       = "https://github.mydomain.com"  # New: GitHub Enterprise host name; defaults to https://github.com
    # }

    # vsts_configuration ={
    #     account_name    = "example-vsts-account"
    #     branch_name     = "main"
    #     project_name    = "example-project"
    #     repository_name = "example-repo"
    #     root_folder     = "/"
    #     tenant_id       = "00000000-0000-0000-0000-000000000000"
    #     publishing_enabled = true
    # }

    global_parameter = {
      praram1 = {
        name  = "example_param"
        type  = "String"
        value = "example_value"
      }
    }
    #customer_managed_key_id         = "https://example-keyvault.vault.azure.net/keys/example-key"
    #customer_managed_key_identity_id = "example-identity-id"
    #purview_id                      = "example-purview-id"

    # New: options for the auto-generated Key Vault secret holding the data factory credential password
    # secret_name         = ""            # Optional: Override the auto-generated secret name (default: <data-factory-name>-secret)
    # secret_content_type = "text/plain"   # Optional
    # secret_not_before_date = "2026-01-01T00:00:00Z"  # Optional
    # secret_expiration_date = "2027-01-01T00:00:00Z"  # Optional
    # secret_tags = { environment = "example" }        # Optional

    # New: options for the Key Vault linked service (azurerm_data_factory_linked_service_key_vault)
    # key_vault_linked_service = {
    #   name                      = ""                 # Optional: Override the auto-generated name (default: <data-factory-name>-kv-linked-service)
    #   description               = "Linked service to Key Vault"
    #   integration_runtime_name  = "example-integration-runtime"
    #   annotations               = ["example"]
    #   parameters                = { example = "value" }
    #   additional_properties     = { example = "value" }
    # }

    service_principal = {
      # name        = ""  # Optional: Override the auto-generated name (default: <data-factory-name>-spn)
      description = "example-service-principle-description"
      annotations = ["1", "2"]
    }
    user_assigned_identity = {
      name = "example-user-assigned-identity"
      # isolation_scope = "Regional"        # New in azurerm >= 5.0: optional
      # tags            = { environment = "example" }  # New: optional, defaults to the module's tags
    }
    user_managed_identity = {
      description = "Short description of this credential"
      annotations = ["example", "example2"]
    }
    private_endpoint = {
      adf = {                               # Key defines the userDefinedstring
        resource_group    = "Project"       # Required: Resource group name, i.e Project, Management, DNS, etc, or the resource group ID
        subnet            = "RZ"            # Required: Subnet name, i.e OZ,MAZ, etc, or the subnet ID
        subresource_names = ["dataFactory"] # Required: Subresource name determines to what service the private endpoint will connect to. see: https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource for list of subresrouce
        # local_dns_zone    = "privatelink.dataFactory.core.windows.net" # Optional: Name of the local DNS zone for the private endpoint
        # New in private_endpoint module >= v1.2.0 (added to the child module's own opaque config object):
        # private_connection_resource_alias = ""   # Optional: use instead of private_connection_resource_id
        # request_message                    = ""   # Optional: only applies when is_manual_connection = true
        # custom_network_interface_name      = ""   # Optional
        # ip_configuration = [
        #   { name = "example", private_ip_address = "10.0.0.4" }
        # ]
      }
    }
  }
}
