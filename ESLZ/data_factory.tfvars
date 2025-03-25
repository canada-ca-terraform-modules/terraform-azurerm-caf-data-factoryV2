data_factories = {
    df1 = {
        resource_group                = "Project"
        key_vault_group = "Keyvault"
        managed_virtual_network_enabled = true
        public_network_enabled      = true
        identity ={
            type = "SystemAssigned"
        }
        # github_configuration ={
        #     account_name    = "example-account"
        #     branch_name     = "main"
        #     repository_name = "example-repo"
        #     root_folder     = "/"
        #     publishing_enabled = true
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

        global_parameter ={
            praram1 ={
                name  = "example_param"
                type  = "String"
                value = "example_value"
            }
        }
        #customer_managed_key_id         = "https://example-keyvault.vault.azure.net/keys/example-key"
        #customer_managed_key_identity_id = "example-identity-id"
        #purview_id                      = "example-purview-id"

        service_principal={
            description = "example-service-principle-description"
            annotations = ["1", "2"]
        }
        user_assigned_identity ={
            name = "example-user-assigned-identity"
            
        }
        user_managed_identity={
            description     = "Short description of this credential"
            annotations = ["example", "example2"]
        }
        private_endpoint = {
          adf = {                                                  # Key defines the userDefinedstring
            resource_group    = "Project"                           # Required: Resource group name, i.e Project, Management, DNS, etc, or the resource group ID
            subnet            = "RZ"                                # Required: Subnet name, i.e OZ,MAZ, etc, or the subnet ID
            subresource_names = ["dataFactory"]                            # Required: Subresource name determines to what service the private endpoint will connect to. see: https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource for list of subresrouce
            # local_dns_zone    = "privatelink.dataFactory.core.windows.net" # Optional: Name of the local DNS zone for the private endpoint
          }
        }
    }
}