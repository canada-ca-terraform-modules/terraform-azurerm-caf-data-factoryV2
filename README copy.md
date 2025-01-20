# terraform-azurerm-caf-windows_clusterV2
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | github.com/canada-ca-terraform-modules/terraform-azurerm-caf-load_balancer.git | n/a |
| <a name="module_windows_VMs"></a> [windows\_VMs](#module\_windows\_VMs) | github.com/canada-ca-terraform-modules/terraform-azurerm-caf-windows_virtual_machineV2.git | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_availability_set.availability_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set) | resource |
| [azurerm_network_interface_backend_address_pool_association.LB_VMs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | (Required) 4 character string defining the environment name prefix for the VM | `string` | `"dev"` | no |
| <a name="input_group"></a> [group](#input\_group) | (Required) Character string defining the group for the target subscription | `string` | `"test"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location for the VM | `string` | `"canadacentral"` | no |
| <a name="input_project"></a> [project](#input\_project) | (Required) Character string defining the project for the target subscription | `string` | `"test"` | no |
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | (Required) Resource group object for the VM | `any` | `{}` | no |
| <a name="input_serverType"></a> [serverType](#input\_serverType) | 3 character string defining the server type for the VM | `string` | `"SWJ"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | (Required) List of subnet objects for the VM | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags that will be applied to every associated VM resource | `map(string)` | `{}` | no |
| <a name="input_userDefinedString"></a> [userDefinedString](#input\_userDefinedString) | (Required) User defined portion value for the name of the VM. | `string` | `"test"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Base64 encoded file representing user data script for the VM | `any` | `null` | no |
| <a name="input_windows_vms_cluster"></a> [windows\_vms\_cluster](#input\_windows\_vms\_cluster) | (Required) Cluster configuration for the HA VMs. | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_VMs"></a> [VMs](#output\_VMs) | The vm module object |
| <a name="output_availability_set"></a> [availability\_set](#output\_availability\_set) | The availability\_set object |
| <a name="output_loaddbalancer"></a> [loaddbalancer](#output\_loaddbalancer) | The availability\_set object |
<!-- END_TF_DOCS -->