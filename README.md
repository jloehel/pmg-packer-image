# Proxmox Mail Gateway packer template
This repository provides a Hashicorp packer template to generate images for:

- Vagrant
  - Virtualbox
  - Libvirt
- AWS EC2
- Microsoft Azure

The Proxmox Mail Gateway 7.3 will get installed. For the Vagrant builds it uses the official ISO:

- ISO: [Proxmox Mail Gateway 7.3 ISO Installer](https://www.proxmox.com/en/downloads/item/proxmox-mail-gateway-7-3-iso-installer)
- Sha256: 9085684327fc36d8006b7160d34733e916300a0ad6bf498ea83cfb901fc2d9d4

The images for AWS and Azure are based on the official cloud images from Debian:

- [Debian Cloud Images - Bullseye](https://cloud.debian.org/images/cloud/bullseye/latest) 

## Build an image
It's necessary to clone and initialize this repo:
~~~console
user@laptop:~$ git clone git@github.com:jloehel/pmg-packer-image.git
user@laptop:~$ cd pmg-packer-image
user@laptop:~$ packer init
user@laptop:~$ packer fmt .
user@laptop:~$ packer validate .
~~~

To increase the verbosity of the packer output please set the 
variable `PACKER_LOG` to `1` like this:
~~~console
user@laptop:~$ PACKER_LOG=1 packer ...
~~~

### Build the VirtualBox Vagrant Box
The build is based on the official ISO from Proxmox.
~~~console
user@laptop:~$ packer build -force -only virtualbox-iso.vagrant .
~~~

### Build the Qemu Vagrant Box
The build is based on the official ISO from Proxmox.
~~~console
user@laptop:~$ packer build -force -only qemu.vagrant .
~~~

### Build the EC2 raw image
The build is based on the official Debian Cloud image for EC2.
The standard user for the EC2 image is `admin`. Please set the 
username and password variable for the build:
~~~console
user@laptop:~$ packer build -force -only qemu.ec2 \
        -var 'ssh_username=admin' \
        -var 'ssh_password=<password>' .
~~~
Packer will set the specified password automatically via cloud-init for the user.

### Build the Azure raw image
The build is based on the official Debian Cloud image for Azure.
The standard user for the Azure image is `debian`. Please set the 
username and password variable for the build:
~~~console
user@laptop:~$ packer build -only qemu.azure \
        -var 'ssh_username=debian' \
        -var 'ssh_password=<password>' .
~~~
Packer will set the specified password automatically via cloud-init for the user.

## Hardening
The cloud images for Azure and Amazon EC2 consider the hardening hints from
[killmasta93](https://github.com/killmasta93/tutorials/wiki/PMG-Harden).

### [DCC](https://www.dcc-servers.net/dcc/)
The DCC (Distributed Checksum Clearinghouses) interface daemon gets installed. It gets
installed as a systemd service:

~~~console
user@laptop:~$ sudo systemctl status dcc
~~~

The checks will be performed by [SpamAssassin](https://spamassassin.apache.org/full/3.1.x/doc/Mail_SpamAssassin_Plugin_DCC.html).

### [Pyzor](https://www.pyzor.org/en/latest/)
The digests of the messages get checked against pyzor via [SpamAssassin](https://spamassassin.apache.org/full/3.1.x/doc/Mail_SpamAssassin_Plugin_Pyzor.html).  

### Geolocation and re2c


### [ClamAV Unoffical Sigs](https://github.com/extremeshok/clamav-unofficial-sigs)
The hardening script will install the ClamAV Unofficial Sigs from [extremeshok](https://github.com/extremeshok).
It's necessary to activate your accounts for:

- malwareexpert
- malwarepatrol

after deploying the image.

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
