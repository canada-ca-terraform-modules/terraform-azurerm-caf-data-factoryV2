data "azurerm_client_config" "current" {}

resource "azurerm_data_factory" "df" {
  name                        = local.data-factory-name
  location                    = var.location
  resource_group_name         = local.resource_group_name
  managed_virtual_network_enabled = try(var.data_factory.managed_virtual_network_enabled,true)
  public_network_enabled      = try(var.data_factory.public_network_enabled, false)

  identity {
    type = var.data_factory.identity.type
    identity_ids = var.data_factory.identity.type == "UserAssigned" ? [azurerm_user_assigned_identity.ui[0].id] :null
  }

  tags                = var.tags

  dynamic github_configuration {
    for_each = try(var.data_factory.github_configuration,null) == null ? [] : [1]
    content{
      account_name    = var.data_factory.github_configuration.account_name
      branch_name     = var.data_factory.github_configuration.branch_name
      repository_name = var.data_factory.github_configuration.repository_name
      root_folder     = var.data_factory.github_configuration.root_folder
      publishing_enabled = var.data_factory.github_configuration.publishing_enabled
    }
  }

dynamic "global_parameter" {
  for_each = try(var.data_factory.global_parameter, {})

  content {
    name  = global_parameter.value.name
    type  = global_parameter.value.type
    value = global_parameter.value.value
  }
}

  dynamic vsts_configuration {
    for_each = try(var.data_factory.vsts_configuration,null) == null ? [] : [1]
    content{
      account_name    = var.data_factory.vsts_configuration.account_name
      branch_name     = var.data_factory.vsts_configuration.branch_name
      project_name    = var.data_factory.vsts_configuration.project_name
      repository_name = var.data_factory.vsts_configuration.repository_name
      root_folder     = var.data_factory.vsts_configuration.root_folder
      tenant_id       = var.data_factory.vsts_configuration.tenant_id
      publishing_enabled = var.data_factory.vsts_configuration.publishing_enabled
    }
  }

  customer_managed_key_id         = try(var.data_factory.customer_managed_key_id, null)
  customer_managed_key_identity_id = try(var.data_factory.customer_managed_key_identity_id, null)
  purview_id                      = try(var.data_factory.purview_id, null)
}

resource "random_string" "password" {
  length           = 20
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  override_special = "_%@"
}

resource "azurerm_key_vault_secret" "secret" {
  name         = "${local.data-factory-name}-secret"
  value        = random_string.password.result
  key_vault_id = var.key_vault.id
}

resource "azurerm_data_factory_linked_service_key_vault" "lskv" {
  name            = "${local.data-factory-name}-kv-linked-service"
  data_factory_id = azurerm_data_factory.df.id
  key_vault_id    = var.key_vault.id
}

resource "azurerm_data_factory_credential_service_principal" "spn" {
  count = try(var.data_factory.service_principal,null) == null ? 0 : 1
  name                 = "${local.data-factory-name}-spn"
  description          = try(var.data_factory.service_principal.description, null)
  data_factory_id      = azurerm_data_factory.df.id
  tenant_id            = data.azurerm_client_config.current.tenant_id
  service_principal_id = data.azurerm_client_config.current.client_id
  service_principal_key {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.lskv.name
    secret_name         = azurerm_key_vault_secret.secret.name
    secret_version      = azurerm_key_vault_secret.secret.version
  }
  annotations = var.data_factory.service_principal.annotations
}

resource "azurerm_user_assigned_identity" "ui" {
  count = try(var.data_factory.user_assigned_identity,null) == null ? 0 : 1
  location            = var.location
  name                = var.data_factory.user_assigned_identity.name
  resource_group_name = local.resource_group_name
    lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_data_factory_credential_user_managed_identity" "mi" {
  count = try(var.data_factory.user_managed_identity,null) == null ? 0 : 1
  name            = azurerm_user_assigned_identity.ui[0].name
  description     = try(var.data_factory.user_managed_identity.description, null)
  data_factory_id = azurerm_data_factory.df.id
  identity_id     = azurerm_user_assigned_identity.ui[0].id

  annotations = var.data_factory.user_managed_identity.annotations
}

# Calls this module if we need a private endpoint attached to the storage account
module "private_endpoint" {
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-private_endpoint.git?ref=v1.0.2"
  for_each =  try(var.data_factory.private_endpoint, {}) 

  name = "${local.data-factory-name}-${each.key}"
  location = var.location
  resource_groups = var.resource_groups
  subnets = var.subnets
  private_connection_resource_id = azurerm_data_factory.df.id
  private_endpoint = each.value
  private_dns_zone_ids = var.private_dns_zone_ids
  tags = var.tags
}