#cloud-config

locale: de_DE.UTF-8
timezone: Europe/Berlin

ntp:
  servers:
    - 0.de.pool.ntp.org
    - 1.de.pool.ntp.org
    - 2.de.pool.ntp.org
    - 3.de.pool.ntp.org

users:
  - default
  - name: ${ansible_user}
    gecos: Ansible User
    groups: users, admin, wheel
    lock_passwd: true
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${ansible_user_key}

datasource:
  Azure:
    apply_network_config: true
    data_dir: /var/lib/waagent
    dhclient_lease_file: /var/lib/dhcp/dhclient.eth0.leases
    disk_aliases:
      ephemeral0: /dev/disk/cloud/azure_resource
    hostname_bounce:
      interface: eth0
      command: builtin
      policy: true
      hostname_command: hostname
    set_hostname: true

package_update: true
package_upgrade: true

packages:
  - apt-transport-https
  - apparmor
  - apparmor-profiles
  - apparmor-utils
  - auditd
  - fail2ban
%{ for package in packages ~}
  - ${package}
%{ endfor ~}

runcmd:
  - echo "AllowUsers ${ansible_user}" >> /etc/ssh/sshd_config
  - systemctl restart ssh

final_message: "The system is finally up, after $UPTIME seconds"
