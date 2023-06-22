data "cloudinit_config" "pmg" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/${var.pmg_settings.config}", {
      packages         = concat(var.base_packages, var.pmg_settings.packages)
      ansible_user     = var.ansible_user,
      ansible_user_key = file(var.ansible_user_key)
    })
  }
}

data "cloudinit_config" "jumpbox" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/${var.jumpbox_settings.config}", {
      packages         = concat(var.base_packages, var.jumpbox_settings.packages)
      ansible_user     = var.ansible_user,
      ansible_user_key = file(var.ansible_user_key)
    })
  }
}
