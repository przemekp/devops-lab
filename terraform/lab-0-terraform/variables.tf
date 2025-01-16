variable "custom_tags" {
  description = "Custom user tags added on top of mandatory tags"
  default     = {}
  type        = map(string)
}

variable "environment" {
  description = "Name of environment"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
}
