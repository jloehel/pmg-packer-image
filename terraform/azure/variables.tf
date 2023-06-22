variable "prefix" {
  description = "Prefix to be used across the different resources to be created"
  default     = "pmg"
}

variable "tf_storage" {
  description = "The name of the storage account for the tfsate"
}

variable "packer_resource_group_name" {
   description = "Name of the resource group in which the Packer image will be created"
   default     = "packer_images"
}

variable "packer_image_name" {
   description = "Name of the Packer image"
   default     = "pm_custom_image"
}

variable "location" {
  description = "The location where all your resources will be created"
  default     = "West Europe"
}

locals {
  name = "${var.prefix}-${random_string.name.result}"
}

variable "ansible_user" {
  description = "The ansible username for the VMs"
  default     = "ansible"
}

variable "ansible_user_key" {
  description = "The SSH public key of the ansible_user"
  default     = "~/.ssh/azure_rsa.pub"
}

variable "postmaster_user_key" {
  description = "The SSH public key of the ansible_user"
  default     = "~/.ssh/postmaster_rsa.pub"
}

variable "base_packages" {
  type    = list(string)
  default = ["vim", "tmux"]
}

variable "jumpbox_settings" {
  description = "The Azure VM settings for the jumpbox"
  default = {
    size      = "Standard_B1ms"
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "22.04.202208100"
    config    = "cloud-init-jumpbox.tpl"
    packages  = []
  }
}

variable "pmg_settings" {
  description = "The Azure VM scale set settings for the Mail Gateway Cluster Nodes"
  default = {
    size         = "Standard_A4_v2"
    config       = "cloud-init-pmg.tpl"
    packages     = []
  }
}
