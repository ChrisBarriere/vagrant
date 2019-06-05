# dotsource du fichier avec les variables d'environnement
. $PSScriptRoot\.env.ps1

# Installation du plugin hostmanager
vagrant plugin install vagrant-hostmanager

# Installation du plugin proxyconf
vagrant plugin install vagrant-proxyconf

# Récupération de la box
vagrant box add --provider hyperv generic/debian9

# Vérification que le répertoire pour les projets existe, si ce n'est pas le cas on le crée
if(!(Test-Path -Path $env:PROJECTS_DIRECTORY)) {
  mkdir $env:PROJECTS_DIRECTORY
}

# Installation de la machine virtuelle via vagrant up (elle sera provisionnée avec shell_init et ansible_local_init)
vagrant up

# Configuration du proxy pour les nouveaux services (git et docker) et on provisionne les services (docker registry, traefik et mailhog)
vagrant provision --provision_with ansible_local_services
