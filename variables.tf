variable "location" {
  description = "Azure location for the data factory"
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Tags that will be applied to every associated data factory resource"
  type        = map(string)
  default     = {}
}

variable "env" {
  description = "(Required) 4 character string defining the environment name prefix for the data factory"
  type        = string
  default     = "dev"
}

# tflint-ignore: terraform_unused_declarations
variable "group" {
  description = "(Required) Character string defining the group for the target subscription"
  type        = string
  default     = "test"
}

# tflint-ignore: terraform_unused_declarations
variable "project" {
  description = "(Required) Character string defining the project for the target subscription"
  type        = string
  default     = "test"
}

variable "userDefinedString" {
  description = "(Required) User defined portion value for the name of the data factory."
  type        = string
  default     = "test"
}

variable "data_factory" {
  description = "(Required) configuration for the data factory."
  type        = any
  default     = null
}

variable "resource_groups" {
  description = "(Required) Map of resource group objects, used to resolve the data factory's resource group by name."
  type        = any
  default     = {}
}

variable "subnets" {
  description = "(Required) Map of subnet objects, used to resolve private endpoint subnets by name."
  type        = any
  default     = {}
}

variable "key_vault" {
  description = "(Required) Key vault object used to host the data factory's generated credential secret."
  type        = any
  default     = {}
}

# tflint-ignore: terraform_unused_declarations
variable "user_data" {
  description = "Base64 encoded file representing user data script (unused by this module; retained for backward compatibility)."
  type        = any
  default     = null
}

variable "private_dns_zone_ids" {
  description = "Object containing the private DNS zone IDs of the subscription. Used to configure private endpoints"
  type        = any
  default     = {}
}
