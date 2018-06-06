# -*- mode: ruby -*-
# # vi: set ft=ruby :

PROJECT_NAME = ENV['PROJECT_NAME'] || File.basename(File.expand_path(File.dirname(__FILE__)))
ANSIBLE_VERSION = ENV['ANSIBLE_VERSION'] || '2.5.4'
ANSIBLE_GALAXY_FORCE = ENV['ANSIBLE_GALAXY_FORCE'] || "--force"
VB_GUEST = ENV['VB_GUEST'] == 'true' ? true : false
SSH_USERNAME = ENV['SSH_USERNAME'] || ''
IP_BASE = 10

Vagrant.configure(2) do |config|


  # The admin VM that is seperate from the kubernetes VMs and contains the development tools.
  config.vm.define "admin" do |vms|
    #      All this to get the ssh username to set in the config.j2 template that goes to ~/.ssh/config. FIXNME glob path is hardcoded to centos/virtualbox
    if (Dir.glob("#{File.dirname(__FILE__)}/.vagrant/machines/centos/virtualbox/*").empty? ||
    ARGV[1] == '--provision' ||
    (ARGV[1] == '--provision-with' && ARGV[2] == 'ansible')) &&
    (SSH_USERNAME.nil? || SSH_USERNAME.empty? || SSH_USERNAME == 'null') && (ARGV[0] == 'up' || ARGV[0] == 'provision')
      print "Enter your ssh username: \n"
      SSH_USERNAME = STDIN.gets.chomp
      print "\n"
    end
    
    vms.vm.box = "boxcutter/centos7-desktop"

    vms.vm.network "private_network", ip: "172.42.42.#{IP_BASE}", netmask: "255.255.255.0",
    auto_config: true

    @syncfolder_type = 'virtualbox'
    if Vagrant::Util::Platform.windows? then
      syncfolder_type = 'nfs'
    end
    vms.vm.synced_folder '../', '/vagrant', type: syncfolder_type , disabled: false
    vms.vm.synced_folder "~/.m2", '/home/vagrant/.m2', type: syncfolder_type , disabled: false
    vms.vm.synced_folder "~/.ssh", '/.ssh', type: syncfolder_type , disabled: false

    vms.vm.provider "virtualbox" do |v|
      v.name = "k8s-dev-admin"
      v.memory = 2028
      v.gui = false
    end

    vms.vm.provision "bootstrapCentos", type: :shell, path: "provision/bootstrap_centos.sh"

    vms.vm.provision "ansible", type: :ansible_local do |ansible|
      ansible.verbose = "v"
      ansible.install_mode = "pip"
      ansible.version = ANSIBLE_VERSION
      ansible.playbook = "#{PROJECT_NAME}/provision/playbook.yml"
      ansible.extra_vars = {
        sshUser: SSH_USERNAME
      }
      ansible.galaxy_role_file = "#{PROJECT_NAME}/provision/requirements.yml"
      ansible.galaxy_roles_path = "#{PROJECT_NAME}/provision/roles"
      ansible.galaxy_command = "ansible-galaxy install --ignore-certs --role-file=%{role_file} --roles-path=%{roles_path} #{ANSIBLE_GALAXY_FORCE}"
      ansible.become = true
    end
  end

  # The kubernetes cluster VMs
  (1..3).each do |i|
    config.vm.define "k8s#{i}" do |s|
      s.ssh.forward_agent = true
      s.vm.box = "ubuntu/xenial64"
      s.vm.hostname = "k8s#{i}"

      s.vm.provision :shell, path: "scripts/bootstrap_ansible.sh"
      if i == 1
        s.vm.provision :shell, inline: "PYTHONUNBUFFERED=1 ansible-playbook /vagrant/ansible/k8s-master.yml -i k8s#{i}, -c local"
      else
        s.vm.provision :shell, inline: "PYTHONUNBUFFERED=1 ansible-playbook /vagrant/ansible/k8s-worker.yml -i k8s#{i}, -c local"
      end

      s.vm.network "private_network", ip: "172.42.42.#{i+IP_BASE}", netmask: "255.255.255.0",
      auto_config: true

      s.vm.provider "virtualbox" do |v|
        v.name = "k8s#{i}"
        v.memory = 3072
        v.gui = false
      end

#      if i != 1
#        # Add a route back to the kubernetes API service
#        s.vm.provision :shell,
#        run: "always",
#        inline: "echo Setting Cluster Route; clustip=$(kubectl --kubeconfig=/home/ubuntu/admin.conf get svc -o json | JSONPath.sh '$.items[?(@.metadata.name=kubernetes)]..clusterIP' -b); node=$(kubectl --kubeconfig=/home/ubuntu/admin.conf get endpoints -o json | JSONPath.sh '$.items[?(@.metadata.name=kubernetes)]..ip' -b); ip route add $clustip/32 via $node || true"
#      end
    end
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = VB_GUEST
  end

  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = true
  end

end
