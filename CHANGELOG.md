# Changelog

All notable changes to this module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## v1.0.0 - 2026-08-20

### Added

- `providers.tf` pinning `azurerm ~> 5.0` and `random ~> 3.0` (none existed before this upgrade).
- `.tflint.hcl` and `ESLZ/.tflint.hcl` (`call_module_type = "local"`), `.gitignore`, `.gitattributes`.
- `tests/data_factory.tftest.hcl` and `tests/upgrade_compat.tftest.hcl` — `terraform test` coverage with `mock_provider`.
- `.github/workflows/terraform-ci.yml` and `.github/workflows/release.yml`.
- `azurerm_data_factory.github_configuration.git_url` — optional GitHub Enterprise host name.
- `azurerm_data_factory.identity.identity_ids` explicit override — lets callers point at an existing user-assigned identity instead of the one this module creates; falls back to the module-created UAMI when `identity.type` contains `UserAssigned` (was previously an exact-match check against `"UserAssigned"` only, missing the combined `"SystemAssigned, UserAssigned"` value).
- `azurerm_data_factory_linked_service_key_vault` — `description`, `integration_runtime_name`, `annotations`, `parameters`, `additional_properties` (all new, previously unexposed).
- `azurerm_key_vault_secret` — `content_type`, `not_before_date`, `expiration_date`, `tags` (all new, previously unexposed).
- `azurerm_user_assigned_identity` — `isolation_scope` (new in azurerm >= 5.0) and `tags` (previously never set on the resource despite a `lifecycle.ignore_changes = [tags]` block already existing for it).
- Optional name overrides (Pattern 12) for every auto-generated resource name: `data_factory.name`, `data_factory.secret_name`, `data_factory.key_vault_linked_service.name`, `data_factory.service_principal.name`.

### Fixed

- `locals.resource_group_name` used an invalid RE2 regex escape sequence (`[^\/]+$`) — forward slash never needs escaping in RE2; changed to `[^/]+$`.
- Removed the dead, never-referenced `locals.kv_resource_group_name`.
- `azurerm_data_factory_credential_service_principal.spn.annotations` and `azurerm_data_factory_credential_user_managed_identity.mi.annotations` previously read `var.data_factory.service_principal.annotations` / `var.data_factory.user_managed_identity.annotations` directly with no `try()` — a caller omitting `annotations` (both are Optional per the provider) hit `Unsupported attribute`. Both now default to `null`.
- `output.data_factory` now sets `sensitive = true` (exposes the full resource object).

### Changed

- Bumped the `private_endpoint` child module pin from `v1.0.2` to `v1.2.0` (adds `private_connection_resource_alias`, `request_message`, `custom_network_interface_name`, `ip_configuration` to that module's own `private_endpoint` object; also adds its own first `providers.tf` pinning `azurerm ~> 5.0`).
- Bumped `ESLZ/data_factory.tf`'s own `?ref=` — previously unpinned (floating on the default branch) — to `v1.0.0`, this module's first tagged release, since this upgrade adds `providers.tf` for the first time.
- Fixed copy-paste variable descriptions inherited from an unrelated VM/PostgreSQL module template (`location`, `tags`, `env`, `resource_groups`, `subnets`, `key_vault`, `user_data`, `userDefinedString`).

### Notes

- `variable "user_data"` is accepted (and wired by the `ESLZ/data_factory.tf` wrapper) but is not consumed by any resource in this module — retained for caller backward compatibility (Key invariant: never remove a variable a caller passes) and marked `# tflint-ignore: terraform_unused_declarations`. Not wired to any resource in this change, since the intended target attribute was never defined by the original author and inventing one is out of scope for a provider-version upgrade.
- `azurerm_key_vault_secret`'s new `value_wo`/`value_wo_version` (ephemeral, write-only value) were intentionally not added: this module always generates its own secret value via `random_string.password.result` through the existing `value` argument, so the mutually-exclusive `value_wo` path doesn't apply to how this module is used today.

### Known blockers

- None.
