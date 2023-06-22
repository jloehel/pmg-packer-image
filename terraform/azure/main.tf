terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.70.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.1.0"
    }
  }

  # https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli
  backend "azurerm" {
      resource_group_name  = "terraform"
      storage_account_name = "${tf_storage}"
      container_name       = "tfstate4pmg"
      key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = local.name
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${local.name}-vnet"
  address_space       = ["10.0.22.0/30", "10.0.25.0/27"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

output "ssh_config" {
  value = templatefile("${path.module}/ssh_config.tpl", {
      ansible_user = var.ansible_user,
      ansible_key  = var.ansible_user_key,
      jumpbox_host = azurerm_public_ip.jumpbox.fqdn,
      pmg_nodes    = "azure-pmg*"
  })
}
