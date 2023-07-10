packer {
  required_version = ">= 1.8.6"
  required_plugins {
    git = {
      version = ">= 0.3.3"
      source  = "github.com/ethanmdavidson/git"
    }
  }
}

data "git-repository" "cwd" {}

locals {
  build_by          = "Built by: HashiCorp Packer ${packer.version}"
  build_date        = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  build_version     = data.git-repository.cwd.head
  build_description = "Version: ${local.build_version}\nBuilt on: ${local.build_date}\n${local.build_by}"
  debian_cloud_images = "https://cloud.debian.org/images/cloud/bookworm/latest"
}

source "qemu" "ec2" {
  accelerator = var.accelerator
  boot_wait          = "5s"
  disk_detect_zeroes = "unmap"
  disk_discard       = "unmap"
  disk_interface     = "virtio-scsi"
  disk_size          = var.disk_size
  format             = "raw"
  headless           = var.headless
  http_directory     = "http"
  disk_image         = true
  skip_resize_disk   = true
  use_backing_file   = false
  iso_checksum       = "file:${local.debian_cloud_images}/SHA512SUMS"
  iso_url            = "${local.debian_cloud_images}/debian-12-ec2-amd64.tar.xz"
  machine_type       = "pc"
  net_device         = "virtio-net-pci"
  output_directory   = "artifacts/ec2"
  cd_files = [
    "${path.root}/cdrom/ec2/meta-data"
  ]
  cd_content = {
    user-data = templatefile(
        "${path.root}/cdrom/ec2/user-data",
        { password = "${var.ssh_password}" }
    )
  }
  cd_label = "cidata"
  qemuargs = [
    ["-m", "${var.memory}M"],
  ]
  shutdown_command   = "sudo systemctl poweroff -i"
  ssh_password       = var.ssh_password
  ssh_port           = var.ssh_port
  ssh_username       = var.ssh_username
  ssh_wait_timeout   = "60m"
  vm_name            = "${var.name}-${var.version}-${var.arch}-ec2.raw"
  vnc_bind_address   = "0.0.0.0"
  vnc_port_max       = 5920
  vnc_port_min       = 5900
}

source "qemu" "azure" {
  accelerator = var.accelerator
  boot_wait          = "5s"
  disk_detect_zeroes = "unmap"
  disk_discard       = "unmap"
  disk_interface     = "virtio-scsi"
  disk_size          = var.disk_size
  format             = "raw"
  headless           = var.headless
  http_directory     = "http"
  disk_image         = true
  skip_resize_disk   = true
  use_backing_file   = false
  iso_checksum       = "file:${local.debian_cloud_images}/SHA512SUMS"
  iso_url            = "${local.debian_cloud_images}/debian-12-azure-amd64.tar.xz"
  machine_type       = "pc"
  net_device         = "virtio-net-pci"
  output_directory   = "artifacts/azure"
  cd_files = [
    "${path.root}/cdrom/azure/meta-data"
  ]
  cd_content = {
    user-data = templatefile(
        "${path.root}/cdrom/azure/user-data",
        { password = "${var.ssh_password}" }
      )
  }
  cd_label = "cidata"
  qemuargs = [
    ["-m", "${var.memory}M"],
  ]
  shutdown_command   = "sudo systemctl poweroff -i"
  ssh_password       = var.ssh_password
  ssh_port           = var.ssh_port
  ssh_username       = var.ssh_username
  ssh_wait_timeout   = "60m"
  vm_name            = "${var.name}-${var.version}-${var.arch}-azure.raw"
  vnc_bind_address   = "0.0.0.0"
  vnc_port_max       = 5920
  vnc_port_min       = 5900
}

source "qemu" "vagrant" {
  accelerator = var.accelerator
  boot_command = [
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
  disk_size          = var.disk_size
  disk_compression   = true
  format             = "qcow2"
  headless           = var.headless
  http_directory     = "http"
  http_port_max      = 10089
  http_port_min      = 10082
  iso_checksum       = "0d709d8ff818def7de15b0c9cd09b01d8fc98fb6b7d6926960a38be9ce47e871"
  iso_url            = "https://proxmox.com/en/downloads?task=callelement&format=raw&item_id=694&element=f85c494b-2b32-4109-b8c1-083cca2b7db6&method=download&args[0]=0d3a4285a8c4ef18242ece539b56fb75"
  machine_type       = "pc"
  net_device         = "virtio-net-pci"
  output_directory   = "artifacts/vagrant/kvm"
  qemuargs           = [["-m", "${var.memory}M"]]
  shutdown_command   = "shutdown -P now"
  ssh_password       = var.ssh_password
  ssh_port           = var.ssh_port
  ssh_username       = var.ssh_username
  ssh_wait_timeout   = "60m"
  vm_name            = "${var.name}-${var.version}-${var.arch}-vagrant.qcow2"
  vnc_bind_address   = "0.0.0.0"
  vnc_port_max       = 5920
  vnc_port_min       = 5900
}

source "virtualbox-iso" "vagrant" {
  guest_os_type        = "Debian11_64"
  guest_additions_path = "VBoxGuestAdditions_{{ .Version }}.iso"
  boot_command = [
    "<enter><wait30>",
    "<leftAltOn>g<leftAltOff><wait2>",
    "<leftAltOn>n<leftAltOff><wait2>",
    "United Sta<wait1><enter><wait2>",
    "<tab><wait1><enter><wait1><up><wait1><enter>",
    "<leftAltOn>n<leftAltOff><wait2>",
    "${var.ssh_password}<tab><wait>",
    "${var.ssh_password}<tab><wait>",
    "${var.email}",
    "<leftAltOn>n<leftAltOff><wait2>",
    "${var.hostname}.${var.domain}<enter><wait2>",
    "<leftAltOn>n<leftAltOff><wait2>",
    "<leftAltOn>i<leftAltOff><wait350>",
  ]
  boot_wait               = "5s"
  disk_size               = var.disk_size
  headless                = var.headless
  format                  = "ova"
  iso_checksum            = "0d709d8ff818def7de15b0c9cd09b01d8fc98fb6b7d6926960a38be9ce47e871"
  iso_url                 = "https://proxmox.com/en/downloads?task=callelement&format=raw&item_id=694&element=f85c494b-2b32-4109-b8c1-083cca2b7db6&method=download&args[0]=0d3a4285a8c4ef18242ece539b56fb75"
  output_directory        = "artifacts/vagrant/virtualbox"
  shutdown_command        = "shutdown -P now"
  ssh_password            = var.ssh_password
  ssh_port                = var.ssh_port
  ssh_username            = var.ssh_username
  ssh_wait_timeout        = "60m"
  vm_name                 = "${var.name}-${var.version}-${var.arch}.ova"
  virtualbox_version_file = ".virtualbox_version"
  vboxmanage = [
    [
      "modifyvm",
      "{{ .Name }}",
      "--memory",
      "${var.memory}"
    ],
    [
      "modifyvm",
      "{{ .Name }}",
      "--cpus",
      "${var.cpus}"
    ],
    [
      "modifyvm",
      "{{ .Name }}",
      "--nictype1",
      "virtio"
    ],
    [
      "modifyvm",
      "{{ .Name }}",
      "--rtcuseutc",
      "on"
    ],
    [
      "modifyvm",
      "{{ .Name }}",
      "--natdnshostresolver1",
      "on"
    ]
  ]
}

build {

  source "virtualbox-iso.vagrant" {
    name = "virtualbox"
  }

  source "qemu.vagrant" {
    name = "libvirt"
  }

  sources = [
    "source.virtualbox-iso.vagrant",
    "source.qemu.vagrant",
    "source.qemu.ec2",
    "source.qemu.azure"
  ]

  provisioner "shell" {
    only = [
      "virtualbox-iso.vagrant",
      "qemu.vagrant"
    ]
    environment_vars = [
      "PACKER_BUILD_NAME=var.name",
      "BUILD_TARGET=vagrant"
    ]
    scripts = [
      "scripts/pmg.sh",
      "scripts/hardening.sh"
    ]
  }

  provisioner "shell" {
    only = [
      "qemu.ec2",
      "qemu.azure"
    ]
    environment_vars = [
      "PACKER_BUILD_NAME=var.name",
      "BUILD_TARGET=cloud",
      "DOMAIN=var.domain",
      "HOSTNAME=var.hostname"
    ]
    scripts = [
      "scripts/pmg.sh",
      "scripts/hardening.sh"
    ]
  }

  provisioner "shell" {
    only = [
      "virtualbox-iso.vagrant",
      "qemu.vagrant"
    ]
    scripts = [
      "scripts/vagrant/user.sh",
      "scripts/vagrant/updates.sh",
      "scripts/vagrant/ssh.sh"
    ]
  }

  provisioner "shell" {
    only = [
      "virtualbox-iso.vagrant"
    ]
    scripts = [
      "scripts/virtualbox.sh"
    ]
  }

  provisioner "shell" {
    only = [
      "qemu.vagrant"
    ]
    scripts = [
      "scripts/qemu.sh"
    ]
  }

  provisioner "shell" {
    only = [
      "qemu.ec2",
      "qemu.azure"
    ]
    environment_vars = [
      "BUILD_TARGET=cloud"
    ]
    scripts = [
      "scripts/cleanup/cloud.sh"
    ]
  }

  provisioner "shell" {
    only = [
      "virtualbox-iso.vagrant",
      "qemu.vagrant"
    ]
    scripts = [
      "scripts/cleanup/common.sh",
      "scripts/cleanup/dhcp.sh",
      "scripts/cleanup/package-manager.sh",
      "scripts/cleanup/logfiles.sh",
      "scripts/cleanup/zerodisk.sh"
    ]
  }

  post-processor "checksum" {
    only = [
      "virtualbox-iso.vagrant",
      "qemu.vagrant"
    ]
    checksum_types      = ["md5", "sha1", "sha256", "sha512"]
    keep_input_artifact = true
    output = "artifacts/vagrant/${source.name}/${var.name}-${var.version}-${var.arch}-vagrant.checksum"
  }


  post-processor "checksum" {
    only = [
      "qemu.ec2",
      "qemu.azure"
    ]
    checksum_types      = ["md5", "sha1", "sha256", "sha512"]
    keep_input_artifact = true
    output = "artifacts/${source.name}/${var.name}-${var.version}-${var.arch}-{{ .BuildName }}.checksum"
  }

  post-processor "manifest" {
    only = [
      "qemu.ec2",
      "qemu.azure"
    ]
    output     = "artifacts/${source.name}/${var.name}-${var.version}-${var.arch}-${source.name}-manifest.json"
    strip_path = true
    strip_time = true
  }

  post-processor "compress" {
    only = [
      "qemu.ec2",
      "qemu.azure"
    ]
    output = "artifacts/${source.name}/${var.name}-${var.version}-${var.arch}-${source.name}.tar.gz"
    format = "tar.gz"
    keep_input_artifact = false
  }

  post-processor "manifest" {
    only = [
      "virtualbox-iso.vagrant",
      "qemu.vagrant"
    ]
    output     = "artifacts/vagrant/${source.name}/${var.name}-${var.version}-${var.arch}-vagrant-manifest.json"
    strip_path = true
    strip_time = true
  }

  post-processor "vagrant" {
    only = [
      "virtualbox-iso.vagrant-virtualbox",
      "qemu.vagrant-qcow2"
    ]
    output              = "images/vagrant-{{ .Provider }}/${var.name}.box"
    # vagrantfile_template = "Vagrantfile.template"
    keep_input_artifact = true
    compression_level   = 9
  }

}
