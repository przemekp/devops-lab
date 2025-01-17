#--------------------- common variables ---------------------

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tags" {
  description = "Custom user tags added on top of mandatory tags"
  default     = {}
  type        = map(string)
}
