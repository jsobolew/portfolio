variable "group_id" {
  type        = number
  description = "TBD project group id"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "billing_account" {
  type        = string
  description = "Billing account a project is attached to"
}

variable "environment" {
  type        = string
  description = "Development or production environment"
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Valid values for var: test_variable are (dev, prod)."
  }
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "zone" {
  type        = string
  description = "GCP zone"
}