# terraform-azurerm-caf-data-factoryV2

Manages an Azure Data Factory (Version 2), its Key Vault-backed credential
secret, an optional Key Vault linked service, an optional user-assigned
identity and its Data Factory credentials, and any associated private
endpoints.

## Usage

### ESLZ module block (`ESLZ/data_factory.tf`)

```hcl
variable "data_factories" {
  type    = any
  default = {}
}

module "data_factory" {
  for_each           = var.data_factories
  source             = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-data-factoryV2?ref=v1.0.0"
  location           = var.location
  env                = var.env
  group              = var.group
  project            = var.project
  userDefinedString  = each.key
  data_factory       = each.value
  key_vault          = local.Project-kv
  resource_groups    = local.resource_groups_all
  subnets            = local.subnets
  tags               = var.tags
}
```

### ESLZ tfvars pattern (`ESLZ/data_factory.tfvars`)

See [ESLZ/data_factory.tfvars](ESLZ/data_factory.tfvars) for a full commented example, including every optional argument added by the `azurerm >= 5.0` upgrade.

## Testing

```bash
terraform fmt -recursive && terraform init -backend=false && terraform validate && terraform test
```

## CI

GitHub Actions workflow at `.github/workflows/terraform-ci.yml` runs fmt, init, validate, test, and tflint on every PR. `.github/workflows/release.yml` tags a GitHub release on merge to `main`, using the version pinned in `ESLZ/data_factory.tf`'s own `?ref=`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 5.1.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_private_endpoint"></a> [private\_endpoint](#module\_private\_endpoint) | github.com/canada-ca-terraform-modules/terraform-azurerm-caf-private_endpoint.git | v1.2.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_data_factory.df](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory) | resource |
| [azurerm_data_factory_credential_service_principal.spn](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_credential_service_principal) | resource |
| [azurerm_data_factory_credential_user_managed_identity.mi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_credential_user_managed_identity) | resource |
| [azurerm_data_factory_linked_service_key_vault.lskv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_linked_service_key_vault) | resource |
| [azurerm_key_vault_secret.secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_user_assigned_identity.ui](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_string.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_factory"></a> [data\_factory](#input\_data\_factory) | (Required) configuration for the data factory. | `any` | `null` | no |
| <a name="input_env"></a> [env](#input\_env) | (Required) 4 character string defining the environment name prefix for the data factory | `string` | `"dev"` | no |
| <a name="input_group"></a> [group](#input\_group) | (Required) Character string defining the group for the target subscription | `string` | `"test"` | no |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | (Required) Key vault object used to host the data factory's generated credential secret. | `any` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location for the data factory | `string` | `"canadacentral"` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Object containing the private DNS zone IDs of the subscription. Used to configure private endpoints | `any` | `{}` | no |
| <a name="input_project"></a> [project](#input\_project) | (Required) Character string defining the project for the target subscription | `string` | `"test"` | no |
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | (Required) Map of resource group objects, used to resolve the data factory's resource group by name. | `any` | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | (Required) Map of subnet objects, used to resolve private endpoint subnets by name. | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags that will be applied to every associated data factory resource | `map(string)` | `{}` | no |
| <a name="input_userDefinedString"></a> [userDefinedString](#input\_userDefinedString) | (Required) User defined portion value for the name of the data factory. | `string` | `"test"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Base64 encoded file representing user data script (unused by this module; retained for backward compatibility). | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_factory"></a> [data\_factory](#output\_data\_factory) | The data\_factory object |
<!-- END_TF_DOCS -->
