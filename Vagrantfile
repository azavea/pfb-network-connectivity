# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.8"


PFB_SHARED_FOLDER_TYPE = ENV.fetch("PFB_SHARED_FOLDER_TYPE", "nfs")

if PFB_SHARED_FOLDER_TYPE == "nfs"
  if Vagrant::Util::Platform.linux? then
    PFB_MOUNT_OPTIONS = ['rw', 'vers=3', 'tcp', 'nolock', 'actimeo=1']
  else
    PFB_MOUNT_OPTIONS = ['vers=3', 'udp', 'actimeo=1']
  end
else
  if ENV.has_key?("PFB_MOUNT_OPTIONS")
    PFB_MOUNT_OPTIONS = ENV.fetch("PFB_MOUNT_OPTIONS").split
  else
    PFB_MOUNT_OPTIONS = ["rw"]
  end
end
VAGRANT_NETWORK_OPTIONS = { auto_correct: false }

ROOT_VM_DIR = "/vagrant"

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "pfb-network-connectivity"
  config.vm.network :private_network, ip: ENV.fetch("PFB_PRIVATE_IP", "192.168.111.111")

  config.vm.network :forwarded_port, guest: 9200, host: ENV.fetch("PFB_NGINX_PORT", 9200)
  config.vm.network :forwarded_port, guest: 9202, host: ENV.fetch("PFB_GUNICORN_PORT", 9202)
  config.vm.network :forwarded_port, guest: 9203, host: ENV.fetch("PFB_RUNSERVER_PORT", 9203)
  config.vm.network :forwarded_port, guest: 5432, host: ENV.fetch("PFB_ANALYSIS_DB_PORT", 9214)
  config.vm.network :forwarded_port, guest: 9301, host: ENV.fetch("PFB_REPOSITORY_PORT", 9301)
  config.vm.network :forwarded_port, guest: 9302, host: ENV.fetch("PFB_REPOSITORY_PORT", 9302)

  config.vm.synced_folder "~/.aws", "/home/vagrant/.aws"
  config.vm.synced_folder '.', ROOT_VM_DIR, type: PFB_SHARED_FOLDER_TYPE, mount_options: PFB_MOUNT_OPTIONS

  config.vm.provision "shell" do |s|
    s.path = 'deployment/vagrant/cd_shared_folder.sh'
    s.args = "'#{ROOT_VM_DIR}'"
  end

  # Upgrade ssl-related packages so that Ansible will install
  # If this provisioner is no longer necessary, the install_pip.sh provisioner can be removed
  # as well.
  # We need to pre-install pip manually since it isn't installed until the ansible_local
  # provisioner runs.
  config.vm.provision "shell", path: 'deployment/vagrant/install_pip.sh'
  config.vm.provision "shell", inline: 'pip install urllib3 pyopenssl ndg-httpsclient pyasn1'

  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "deployment/ansible/pfb.yml"
    ansible.galaxy_role_file = "deployment/ansible/roles.yml"
    ansible.verbose = true
    ansible.raw_arguments = ["--timeout=60",
                             "--extra-vars",
                             "dev_user=#{ENV.fetch("USER", "vagrant")}"]

    # local arguments
    # Ubuntu trusty base box already has system python + pip installed, no need to reinstall here
    ansible.install = true
    ansible.install_mode = "pip"
    ansible.version = "2.2.1.0"
  end

  config.vm.provider :virtualbox do |v|
    v.memory = ENV.fetch("PFB_MEM", 4096)
    v.cpus = ENV.fetch("PFB_CPUS", 8)
  end
end
