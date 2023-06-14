# Proxmox Mail Gateway packer template

- ISO: [Proxmox Mail Gateway 7.3 ISO Installer](https://www.proxmox.com/en/downloads/item/proxmox-mail-gateway-7-3-iso-installer)
- Sha256: 9085684327fc36d8006b7160d34733e916300a0ad6bf498ea83cfb901fc2d9d4

## Build image

~~~console
user@laptop:~$ git clone git@github.com:jloehel/pmg-packer-image.git
user@laptop:~$ cd pmg-packer-image
user@laptop:~$ packer init
user@laptop:~$ packer build proxmox73.pkr.hcl
~~~
