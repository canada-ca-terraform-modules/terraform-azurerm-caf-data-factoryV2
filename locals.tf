locals {
  resource_group_name = strcontains(var.data_factory.resource_group, "/resourceGroups/") ? regex("[^\\/]+$", var.data_factory.resource_group) :  var.resource_groups[var.data_factory.resource_group].name
  kv_resource_group_name = strcontains(var.data_factory.key_vault_group, "/resourceGroups/") ? regex("[^\\/]+$", var.data_factory.key_vault_group) :  var.resource_groups[var.data_factory.key_vault_group].name
}