variable "env" {
  description = "Environment prefix used in the generated Data Factory name"
  type        = string
  default     = "livetest"
}

variable "group" {
  description = "Group for the target subscription (passed straight through to the module under test)"
  type        = string
  default     = "test"
}

variable "project" {
  description = "Project for the target subscription (passed straight through to the module under test)"
  type        = string
  default     = "test"
}

variable "location" {
  description = "Location for the throwaway live-test resource group (+ key vault)"
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Tags applied to the resources created by this harness"
  type        = map(string)
  default = {
    purpose = "module-live-test"
  }
}

variable "pr_number" {
  description = <<-EOT
    Suffix applied to test_dependencies.tf resource names so concurrent PRs
    against this module never collide on the same sandbox subscription. CI
    sources this from `TF_VAR_pr_number` (`github.event.number`); manual runs
    can leave the default or pass their own value.
  EOT
  type        = string
  default     = "manual"
}

variable "data_factory" {
  description = "(Required) Data Factory configuration object, passed straight through to the module under test"
  type        = any
}
