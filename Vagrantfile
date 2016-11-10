# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.8"

VAGRANT_MOUNT_OPTIONS = if Vagrant::Util::Platform.linux? then
  ['rw', 'vers=4', 'tcp', 'nolock']
else
  ['vers=3', 'udp']
end
VAGRANT_NETWORK_OPTIONS = { auto_correct: false }

ROOT_VM_DIR = "/vagrant"

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "pfb-network-connectivity"
  config.vm.network "private_network", ip: ENV.fetch("PFB_PRIVATE_IP", "192.168.111.111")

  config.vm.network "forwarded_port", guest: 5432, host: 5442

  config.vm.synced_folder '.', ROOT_VM_DIR, type: "nfs", mount_options: VAGRANT_MOUNT_OPTIONS

  config.vm.provision "shell" do |s|
    s.path = 'deployment/vagrant/cd_shared_folder.sh'
    s.args = "'#{ROOT_VM_DIR}'"
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "deployment/ansible/pfb-analysis.yml"
    ansible.galaxy_role_file = "deployment/ansible/roles.yml"
    ansible.verbose = true
    ansible.raw_arguments = ["--timeout=60"]
  end

  config.vm.provider :virtualbox do |v|
    v.memory = ENV.fetch("PFB_MEM", 4096)
    v.cpus = ENV.fetch("PFB_CPUS", 4)
  end
end
