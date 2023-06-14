locals {
  buildtime = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
}

variable "domain" {
  type    = string
  default = "lab.local"
}

variable "email" {
  type    = string
  default = "postmaser@lab.local"
}

variable "hostname" {
  type    = string
  default = "pmg"
}

variable "ssh_password" {
  type    = string
  default = "linux"
}

source "qemu" "proxmox" {
  accelerator        = "tcg"
  boot_command       = [
    "<enter><wait200>",
    "<leftAltOn>g<leftAltOff><wait>",
    "<leftAltOn>n<leftAltOff><wait60>",
    "United Sta<wait2><enter><wait5>",
    "<tab><wait2><enter><wait2><up><wait2><enter>",
    "<leftAltOn>n<leftAltOff><wait30>",
    "${var.ssh_password}<tab><wait>",
    "${var.ssh_password}<tab><wait>",
    "${var.email}",
    "<leftAltOn>n<leftAltOff><wait30>",
    "${var.hostname}.${var.domain}<enter><wait10>",
    "<leftAltOn>n<leftAltOff><wait30>",
    "<leftAltOn>i<leftAltOff><wait1200>",
  ]
  boot_wait          = "5s"
  disk_detect_zeroes = "unmap"
  disk_discard       = "unmap"
  disk_interface     = "virtio-scsi"
  disk_size          = 32768
  format             = "qcow2"
  headless           = false
  http_directory     = "http"
  http_port_max      = 10089
  http_port_min      = 10082
  iso_checksum       = "df3bdb62368c7d1df1fc8a0d96cef7e5d8ab8758"
  iso_url            = "https://www.proxmox.com/en/downloads?task=callelement&format=raw&item_id=684&element=f85c494b-2b32-4109-b8c1-083cca2b7db6&method=download&args[0]=7dc4968fa252f658301a94368b944183"
  iso_target_path    = "./ISOs"
  machine_type       = "pc"
  net_device         = "virtio-net-pci"
  output_directory   = "output"
  qemuargs           = [["-m", "2048M"]]
  shutdown_command   = "shutdown -P now"
  ssh_password       = "${var.ssh_password}"
  ssh_port           = 22
  ssh_username       = "root"
  ssh_wait_timeout   = "60m"
  vm_name            = "proxmox73-amd64-qemu"
  vnc_bind_address   = "0.0.0.0"
  vnc_port_max       = 5900
  vnc_port_min       = 5900
}

build {
  sources = ["source.qemu.proxmox"]

  provisioner "shell" {
    scripts = ["scripts/provision.sh", "scripts/networking.sh"]
  }

}
