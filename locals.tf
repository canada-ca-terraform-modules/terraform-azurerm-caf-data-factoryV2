locals {
  resource_group_name = strcontains(var.data_factory.resource_group, "/resourceGroups/") ? regex("[^/]+$", var.data_factory.resource_group) : var.resource_groups[var.data_factory.resource_group].name
}
