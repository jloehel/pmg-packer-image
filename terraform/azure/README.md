## Create the infrastructure for a Proxmox Mail Gateway on Azure
~~~console
user@laptop:~$ terraform init -upgrade
user@laptop:~$ terraform plan -out main.tfplan
user@laptop:~$ terraform apply main.tfplan
~~~

## Destroy the infrastructure for a Proxmox Mail Gateway on Azure
~~~console
user@laptop:~$ terraform plan -destroy -out main.destroy.tfplan
~~~
