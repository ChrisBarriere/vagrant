Pour pouvoir utiliser Vagrant, il faut avoir un système de virtualisation installé.
Pour Windows, il est recommandé d'utiliser VirtualBox. Mais VirtualBox et Hyper-V ne peuvent pas être utilisés en même temps.
Vu que j'utilise déjà Hyper-V dans d'autres projets pour mes Docker Machine, je vais utiliser Hyper-V comme provider pour Vagrant.


Les commandes seront lancés avec un PowerShell exécuté avec des droits d'administrateur

## 1. Activer Hyper-V sur Windows 10:

- [ ] `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All`
- [ ] Reboot


## 2. Installer Vagrant:

- [ ] Installation de Vagrant à l'aide du paquet MSI récupéré sur le site officiel
- [ ] Reboot
- [ ] Vérification que vagrant est installé : `vagrant -v`

## 3. Mettre-à-jour la version de configuration des VMs Hyper-V
Pour faire fonctionner des box Vagrant récentes, il faut s'assurer d'avoir une version de configuration des VMs au moins égal à 8.3

Pour connaître la version supportée: `Get-VMHostSupportedVersion -Default`

Pour moi c'est **8.2** car ma version de Windows 10 n'est pas très à jour (**Microsoft Windows 10 Fall Creators Update/Server 1709**)

Il faut donc installer la mise-à-jour 18.09 de Windows 10. Bon là faut prévoir entre 1h et 2h...

Je relance `Get-VMHostSupportedVersion -Default`

Et on obtient **9.0** pour la version de configuration supportée.

## 4. Créer un switch interne Hyper-V

Dans le gestionnaire Hyper-V, créer un nouveau switch virtuel nommé **vagrant_switch** de type **interne**

## 5. Téléchargement de la box debian9 pour Hyper-V
`vagrant add box generic/debian9 --provider hyperv`

## 6. Initialisation d'un environnement Vagrant
`vagrant init`

## 7. Modifiction du Vagrantfile
avec le contenu du fichier [ici](./Vagrantfile)

Remarque:
- Compte tenu des limitation hyperv toute la partie network de la configuration n'est pas utilisée


## 8. Lancer l'environnement
`vagrant up`
