# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # Par défut c'est bash -l qu'on change en bash (cf https://superuser.com/questions/1160025/how-to-solve-ttyname-failed-inappropriate-ioctl-for-device-in-vagrant)
  config.ssh.shell="bash"

  # Le nom Vagrant de la VM
  config.vm.define ENV['VM_HYPERV_NAME']

  # La vagrant box à utiliser
  config.vm.box = "generic/debian9"

  # On utilise le provider hyperv
  config.vm.provider "hyperv"

  # Configuration spécifique à hyperv
  config.vm.provider "hyperv" do |hv|
    # Le nom de la machine dans le gestionnaire Hyper-V
  	hv.vmname = ENV['VM_HYPERV_NAME']
  	# Le nombre de cpus à allouer
  	hv.cpus = ENV['VM_CPU']
  	# Mémoire allouée au démarrage
  	hv.memory = ENV['VM_MEMORY_STARTUP']
  	# Mémoire maximale pouvant être allouée dynamiquement
  	hv.maxmemory = ENV['VM_MEMORY_MAX']
  	# Pour améliorer le démarrage d'un vagrant up
  	linked_clone = true
  	# Le timeout pour attendre que la machine renvoie son adresse IP
  	hv.ip_address_timeout = 240
  end

  # Le nom d'hôte de la machine
  config.vm.hostname = ENV['VM_HOSTNAME']

  # Pas de mise-à-jour automatique de la box. Cela sera fait uniquement à la demande(`vagrant box outdated`)
  config.vm.box_check_update = false

  # On met à jour la configuration du proxy (cela permettra de à Vagrant de configurer le proxy dans les variables d'environnement, pour apt, pour git, etc....)
  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = ENV['HTTP_PROXY']
    config.proxy.https    = ENV['HTTPS_PROXY']
    config.proxy.no_proxy = ENV['NO_PROXY']
  end

  # Configuration du plugin hostmanager (il est activé pour pouvoir se déclencher à chaque up ou chaque reload)
  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = false
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.aliases = [ENV['VM_HOSTNAME'] + '.' + ENV['DEV_DOMAIN'], 'registry.docker.' + ENV['DEV_DOMAIN'], 'traefik.' + ENV['DEV_DOMAIN']]
  end

  # Pas de config.vm.network avec le provider hyperv (voir https://www.vagrantup.com/docs/hyperv/limitations.html)

  # Partage de fichier de type smb entre la vm et la machine hôte pour le répertoire courant vagrant
  config.vm.synced_folder ".", "/vagrant", type: "smb",
	  smb_password: ENV['SMB_PASSWORD'], smb_username: ENV['SMB_USERNAME'], mount_options: ["iocharset=utf8","uid=1000","gid=1000","forcegid","forceuid","dynperm"]

  # Partage de fichier de type smb entre la vm et la machine hôte pour mon répertoire avec mes projets
  config.vm.synced_folder "../myprojects", "/myprojects", type: "smb",
	  smb_password: ENV['SMB_PASSWORD'], smb_username: ENV['SMB_USERNAME'], mount_options: ["iocharset=utf8","uid=1000","gid=1000","forcegid","forceuid","dynperm"]

  # ------------------- Provisionnement qui s'exécute une seule fois au up
  # Provisionnement avec un shell pour mettre-à-jour resolvconf avec le DNS Acrylic
  config.vm.provision "shell_init", type:"shell", run: "once" do |shell|
    shell.path = "./provisioning/shell/updateresolvconf.sh"
    shell.args = [ENV['DEV_DOMAIN']]
  end
  # Provisionnement avec ansible en local (étape de configuration qui est lancée automatiquement au up et une seule fois)
  config.vm.provision "ansible_local_init", type:"ansible_local", run: "once" do |ansible|
    ansible.config_file= "/vagrant/provisioning/ansible/.ansible.cfg"
    ansible.playbook = "/vagrant/provisioning/ansible/playbook.yaml"
    ansible.install_mode = "pip"
    ansible.version = "2.8.0"
    ansible.compatibility_mode = "2.0"
    ansible.extra_vars = {
      localdomain: ENV['DEV_DOMAIN']
    }
    ansible.tags = 'configuration'
    ansible.verbose = "-v"
  end

  # ------------------- Provisionnement qui s'exécute à la demande pour les services
  # Provisionnement avec ansible en local (étape de mise en place des services qui doit être lancée manuellement via vagrant provision --provision-with ansible_local_services)
  config.vm.provision "ansible_local_services", type:"ansible_local", run: "never" do |ansible|
    ansible.config_file= "/vagrant/provisioning/ansible/.ansible.cfg"
    ansible.playbook = "/vagrant/provisioning/ansible/playbook.yaml"
    ansible.compatibility_mode = "2.0"
    ansible.extra_vars = {
      localdomain: ENV['DEV_DOMAIN']
    }
    ansible.tags = 'services'
    ansible.verbose = "-v"
  end
end
