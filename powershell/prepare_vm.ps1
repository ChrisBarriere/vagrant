# dotsource du fichier avec les variables d'environnement
. $PSScriptRoot\.env.ps1

# Installation du plugin hostmanager
vagrant plugin install vagrant-hostmanager

# Installation du plugin proxyconf
vagrant plugin install vagrant-proxyconf

# Récupération de la box
vagrant box add --provider hyperv generic/debian9

# Installation de la machine virtuelle via vagrant up (elle sera provisionnée avec shell_init et ansible_local_init)
vagrant up

# On redémarre la machine (on doit le faire pour être sûr que le configuration du proxy est disponible pour git et docker) et on provisionne les services
vagrant reload --provision_with ansible_local_services
