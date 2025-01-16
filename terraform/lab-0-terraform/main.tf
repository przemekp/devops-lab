module "rsg" {
  source = "../modules/rsg"

  location            = var.location
  resource_group_name = "test-rg"
  tags                = local.tags
}

locals {
  mandatory_tags = {
    environment = var.environment
    location    = var.location
    managed_by  = "Terraform"
  }
  tags = merge(local.mandatory_tags, var.custom_tags)
}
