# dotsource du fichier avec les variables d'environnement
. $PSScriptRoot\.env.ps1

# Initialisation d'un environnement vagrant
vagrant init

# Installation du plugin hostmanager
vagrant plugin install vagrant-hostmanager

# Installation du plugin proxyconf
vagrant plugin install vagrant-proxyconf

# Récupération de la box
vagrant box add --provider hyperv generic/debian9

# Installation de la machine virtuelle via vagrant up
vagrant up

# On redémarre la machine et on provisionne les services
vagrant reload --provision_with ansible_local_services
