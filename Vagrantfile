# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

ENV['memory']
ENV['cpus']
ENV['ip_address']

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "box" do |box|
      box.vm.box = "file://images/vagrant-virtualbox/proxmox-mail-gateway-7-3-amd64.box"
      box.vm.network :private_network, ip: "#{ENV['ip_address']}"
      box.vm.hostname = "pmg"
      box.ssh.insert_key = false

      box.vm.provider "virtualbox" do |v|
          v.customize [ "modifyvm", :id, "--cpus", "#{ENV['cpus']}" ]
          v.customize [ "modifyvm", :id, "--memory", "#{ENV['memory']}" ]
      end

  end

end
