variable "accelerator" {
  type    = string
  default = "kvm"
}

variable "cpus" {
  type    = string
  default = "1"
}

variable "disk_size" {
  type    = number
  default = 32768
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "headless" {
  type    = bool
  default = false
}

variable "name" {
  type    = string
  default = "proxmox-mail-gateway"
}

variable "version" {
  type    = string
  default = "7.3"
}

variable "arch" {
  type    = string
  default = "amd64"
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

variable "ssh_username" {
  type    = string
  default = "root"
}

variable "ssh_password" {
  type    = string
  default = "vagrant"
  sensitive = true
}

variable "ssh_port" {
  type    = number
  default = 22
}
