data "azurerm_resource_group" "pmg-image" {
  name                = var.packer_resource_group_name
}

data "azurerm_image" "pmg-image" {
  name                = var.packer_image_name
  resource_group_name = data.azurerm_resource_group.pmg-image.name
}
