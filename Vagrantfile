# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # Le nom Vagrant de la VM
  config.vm.define "my-debian"
  
  # La vagrant box à utiliser
  config.vm.box = "generic/debian9"

  # On utilise le provider hyperv
  config.vm.provider "hyperv"
  
  # Configuration spécifique à hyperv
  config.vm.provider "hyperv" do |hv|
    # Le nom de la machine dans le gestionnaire Hyper-V
	hv.vmname = "debian9"
	# Le nombre de cpus à allouer
	hv.cpus = 2
	# Mémoire allouée au démarrage
	hv.memory = 2048
	# Mémoire maximale pouvant être allouée dynamiquement
	hv.maxmemory = 4096
	# Pour améliorer le démarrage d'un vagrant up
	linked_clone = true
	# Le timeout pour attendre que la machine renvoie son adresse IP
	hv.ip_address_timeout = 240
  end
  
  # Le nom d'hôte de la machine
  config.vm.hostname = "mydebian"

  # Pas de mise-à-jour automatique de la box. Cela sera fait uniquement à la demande(`vagrant box outdated`)
  config.vm.box_check_update = false

  # Pas de config.vm.network avec le provider hyperv

  # Partage de fichier de type smb entre la vm et la machine hôte
  config.vm.synced_folder ".", "/vagrant", type: "smb",
	  smb_password: "Charlie2013&Loup2011", smb_username: "christophe.barriere@AUTH"
  
  # Provisioning
  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "playbook.yml"
  end
  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
