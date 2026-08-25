terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Empty on purpose: the state file path is supplied at `terraform init`
  # time via `-backend-config="path=..."` (partial configuration), so the
  # target-branch checkout and the PR-branch checkout can point at the same
  # external state file without either owning its own local state.
  backend "local" {}
}

provider "azurerm" {
  storage_use_azuread             = true
  resource_provider_registrations = "legacy"
  features {
    key_vault {
      # This harness's Key Vault is fully self-owned by Terraform - safe to
      # purge on destroy every run.
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      # This harness's resource group is fully self-owned by Terraform - no
      # risk of destroying anything not created by this run.
      prevent_deletion_if_contains_resources = false
    }
  }
}

module "data_factory" {
  # PR code and baseline code are two on-disk checkouts of this same repo,
  # not two resolved git refs - no pinned ?ref, no version toggle here.
  source = "../../"

  env               = var.env
  group             = var.group
  project           = var.project
  location          = var.location
  userDefinedString = "livetest"
  data_factory      = var.data_factory
  key_vault         = local.key_vault       # from test_dependencies.tf
  resource_groups   = local.resource_groups # from test_dependencies.tf
  subnets           = {}                    # no private_endpoint exercised by this harness
  tags              = var.tags

  depends_on = [azurerm_role_assignment.live_test_kv_secrets_officer]
}
# no-op touch to satisfy live-test.yml's path filter for PR B
