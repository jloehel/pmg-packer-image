# Proxmox Mail Gateway packer template
This repository provides a Hashicorp packer template to generate images for:

- Vagrant
- AWS EC2
- Microsoft Azure

The Proxmox Mail Gateway 7.3 will get installed. For the Vagrant builds it uses the official ISO:

- ISO: [Proxmox Mail Gateway 7.3 ISO Installer](https://www.proxmox.com/en/downloads/item/proxmox-mail-gateway-7-3-iso-installer)
- Sha256: 9085684327fc36d8006b7160d34733e916300a0ad6bf498ea83cfb901fc2d9d4

The images for AWS and Azure are based on the official cloud images from Debian:

- [Debian Cloud Images - Bullseye](https://cloud.debian.org/images/cloud/bullseye/latest) 

## Build an image
~~~console
user@laptop:~$ git clone git@github.com:jloehel/pmg-packer-image.git
user@laptop:~$ cd pmg-packer-image
user@laptop:~$ packer init
user@laptop:~$ packer fmt .
user@laptop:~$ packer validate .
~~~

### Build the VirtualBox Vagrant Box
~~~console
user@laptop:~$ packer build -only virtualbox-iso.pmg .
~~~

### Build the Qemu Vagrant Box
~~~console
user@laptop:~$ packer build -only qemu.pmg .
~~~

### Build the EC2 raw image
Please set the password for the admin user with cloud-init in `./http/user-data`:
~~~
password: <password>
chpasswd:
  expire: False
ssh_pwauth: True
~~~

Set the password variable during the build:
~~~console
user@laptop:~$ packer build -only qemu.pmg-ec2 \
        -var 'ssh_username=admin' \
        -var 'ssh_password=<password>' .
~~~

### Build the Azure raw image
Please set the password for the admin user with cloud-init in `./http/user-data`:
~~~
password: <password>
chpasswd:
  expire: False
ssh_pwauth: True
~~~

Set the password variable during the build:
~~~console
user@laptop:~$ packer build -only qemu.pmg-azure \
        -var 'ssh_username=admin' \
        -var 'ssh_password=<password>' .
~~~

## Hardening

### DCC
### Geolocation and re2c
### ClamAV Unoffical
### EBL
### fail2ban
The hardening provisioner adds some additional jails for the postfix instance.
#### postfix-auth
#### postfix-pregreet from iRedMail
#### postifx-hangup 

### auditd

## Ansible
TODO

## Terraform
The repository includes also some basic terraform templates for libvirtd, Azure and AWS.

### Libvirtd
### Azure
### AWS
