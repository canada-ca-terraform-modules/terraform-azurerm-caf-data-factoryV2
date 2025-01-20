variable "data_factories" {
  type = any
  default = {}
  description = "Value for data factory. This is a collection of values as defined in data_factory.tfvars"
}

module "data_factory" {

    for_each = var.data_factories
    source = "/home/ken/terraform-azurerm-caf-data-factoryV2"
    location= var.location
    env = var.env
    group = var.group
    project = var.project
    userDefinedString = each.key
    data_factory = each.value
    key_vault = local.Project-kv 
    resource_groups = local.resource_groups_all
    subnets = local.subnets
    user_data = try(each.value.user_data, false) != false ? base64encode(file("${path.cwd}/${each.value.user_data}")) : null
    tags = var.tags
}