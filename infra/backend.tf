terraform {
  backend "azurerm" {
    resource_group_name   = "ansibleDemo"
    storage_account_name  = "ansibledemotfstate"
    container_name        = "tfstate"
    key                   = "demo.terraform.tfstate"
  }
}