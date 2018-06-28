# -*- mode: ruby -*-
# # vi: set ft=ruby :

PROJECT_NAME = ENV['PROJECT_NAME'] || File.basename(File.expand_path(File.dirname(__FILE__)))
ANSIBLE_VERSION = ENV['ANSIBLE_VERSION'] || '2.5.4'
ANSIBLE_GALAXY_FORCE = ENV['ANSIBLE_GALAXY_FORCE'] || "--force"
VB_GUEST = ENV['VB_GUEST'] == 'true' ? true : false
SSH_USERNAME = ENV['SSH_USERNAME'] || ''
IP_BASE = 10
VM_CPUS = ENV['VM_CPUS'] || 2
VM_MEMORY = ENV['VM_MEMORY'] || 4096

Vagrant.configure(2) do |config|

  # The kubernetes cluster VMs
  (1..3).each do |i|
    config.vm.define "k8s#{i}" do |s|
      s.ssh.forward_agent = true
      
      s.vm.box = "bento/ubuntu-16.04"
      s.vm.hostname = "k8s#{i}.vagrant.net"
    
      if Vagrant.has_plugin?("vagrant-hostmanager")
        s.hostmanager.enabled = true
        s.hostmanager.manage_host = true
        s.hostmanager.manage_guest = true
        #s.hostmanager.aliases = "k8s#{i}"
        s.hostmanager.include_offline = true
      end

      s.vm.network "private_network", ip: "172.42.42.#{i+IP_BASE}", netmask: "255.255.255.0",
      auto_config: true

      s.vm.provider "virtualbox" do |v|
        v.name = "k8s#{i}"
        v.memory = VM_MEMORY
        v.gui = false
        v.cpus = VM_CPUS
      end
    end
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = VB_GUEST
  end

end
