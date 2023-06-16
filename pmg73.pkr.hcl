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
  debian_cloud_images = "https://cloud.debian.org/images/cloud/bullseye/latest"
}


source "qemu" "pmg-ec2" {
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
  iso_checksum       = "none"
  iso_url            = "${local.debian_cloud_images}/debian-11-ec2-amd64.tar.xz"
  machine_type       = "pc"
  net_device         = "virtio-net-pci"
  output_directory   = "artifacts/qemu"
  qemuargs = [
    ["-m", "${var.memory}M"],
    ["-smbios", "type=1,serial=ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/"]
  ]
  shutdown_command   = "shutdown -P now"
  ssh_password       = var.ssh_password
  ssh_port           = var.ssh_port
  ssh_username       = var.ssh_username
  ssh_wait_timeout   = "60m"
  vm_name            = "${var.name}-${var.version}-${var.arch}-ec2"
  vnc_bind_address   = "0.0.0.0"
  vnc_port_max       = 5900
  vnc_port_min       = 5900
}

source "qemu" "pmg-azure" {
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
  iso_checksum       = "none"
  iso_url            = "${local.debian_cloud_images}/debian-11-azure-amd64.tar.xz"
  machine_type       = "pc"
  net_device         = "virtio-net-pci"
  output_directory   = "artifacts/qemu"
  qemuargs = [
    ["-m", "${var.memory}M"],
    ["-smbios", "type=1,serial=ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/"]
  ]
  shutdown_command   = "shutdown -P now"
  ssh_password       = var.ssh_password
  ssh_port           = var.ssh_port
  ssh_username       = var.ssh_username
  ssh_wait_timeout   = "60m"
  vm_name            = "${var.name}-${var.version}-${var.arch}-azure"
  vnc_bind_address   = "0.0.0.0"
  vnc_port_max       = 5900
  vnc_port_min       = 5900
}

source "qemu" "pmg" {
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
  iso_checksum       = "9085684327fc36d8006b7160d34733e916300a0ad6bf498ea83cfb901fc2d9d4"
  iso_url            = "https://www.proxmox.com/en/downloads?task=callelement&format=raw&item_id=684&element=f85c494b-2b32-4109-b8c1-083cca2b7db6&method=download&args[0]=e4b8366baa5554db59254c1ad8e81de3"
  machine_type       = "pc"
  net_device         = "virtio-net-pci"
  output_directory   = "artifacts/qemu"
  qemuargs           = [["-m", "${var.memory}M"]]
  shutdown_command   = "shutdown -P now"
  ssh_password       = var.ssh_password
  ssh_port           = var.ssh_port
  ssh_username       = var.ssh_username
  ssh_wait_timeout   = "60m"
  vm_name            = "${var.name}-${var.version}-${var.arch}-kvm"
  vnc_bind_address   = "0.0.0.0"
  vnc_port_max       = 5900
  vnc_port_min       = 5900
}

source "virtualbox-iso" "pmg" {
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
  iso_checksum            = "9085684327fc36d8006b7160d34733e916300a0ad6bf498ea83cfb901fc2d9d4"
  iso_url                 = "https://www.proxmox.com/en/downloads?task=callelement&format=raw&item_id=684&element=f85c494b-2b32-4109-b8c1-083cca2b7db6&method=download&args[0]=e4b8366baa5554db59254c1ad8e81de3"
  output_directory        = "artifacts/virtualbox-iso"
  shutdown_command        = "shutdown -P now"
  ssh_password            = var.ssh_password
  ssh_port                = var.ssh_port
  ssh_username            = var.ssh_username
  ssh_wait_timeout        = "60m"
  vm_name                 = "${var.name}-${var.version}-${var.arch}-virtualbox"
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
  sources = [
    "source.virtualbox-iso.pmg",
    "source.qemu.pmg",
    "source.qemu.pmg-ec2",
    "source.qemu.pmg-azure"
  ]

  provisioner "shell" {
    only = [
      "virtualbox-iso.pmg",
      "quemu.pmg"
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
      "quemu.pmg-ec2",
      "quemu.pmg-azure"
    ]
    environment_vars = [
      "PACKER_BUILD_NAME=var.name",
      "BUILD_TARGET=cloud"
    ]
    scripts = [
      "scripts/pmg.sh",
      "scripts/hardening.sh"
    ]
  }

  provisioner "shell" {
    only = [
      "virtualbox-iso.pmg",
      "quemu.pmg"
    ]
    scripts = [
      "scripts/vagrant/user.sh",
      "scripts/vagrant/updates.sh",
      "scripts/vagrant/ssh.sh"
    ]
  }

  provisioner "shell" {
    only = [
      "virtualbox-iso.pmg"
    ]
    scripts = [
      "scripts/virtualbox.sh",
    ]
  }

  provisioner "shell" {
    only = [
      "quemu.pmg"
    ]
    scripts = [
      "scripts/qemu.sh",
    ]
  }

  provisioner "shell" {
    only = [
      "virtualbox-iso.pmg",
      "quemu.pmg"
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
    checksum_types      = ["md5", "sha1", "sha256"]
    keep_input_artifact = true
    output = "artifacts/{{ .BuilderType }}/{{.BuildName}}_{{.BuilderType}}_{{.ChecksumType}}.checksum"
  }

  post-processor "manifest" {
    output     = "artifacts/manifest.json"
    strip_path = true
    strip_time = true
  }

  post-processor "vagrant" {
    only = [
      "virtualbox-iso.pmg",
      "quemu.pmg"
    ]
    output              = "images/vagrant-{{ .Provider }}/${var.name}.box"
    # vagrantfile_template = "Vagrantfile.template"
    keep_input_artifact = true
    compression_level   = 9
  }

}
