# Introduction
**Contraintes**:
- Je dispose d'une machine Windows 10 avec Hyper-v activé.
- Je dois pouvoir utiliser mon environnement de développement dans plusieurs cas de figure (connexion par carte wi-fi ou par carte ethernet, présence ou non d'un proxy)
- Je veux limiter le nombre de logiciels installés sur ma machine

**Fonctionnalités souhaitées**
- Je souhaite pouvoir disposer d'un environnement de développement évolutif et qui peut être configuré, détruit et redéployé très simplement.
- Je veux pouvoir en une commande changer mon mode de connexion.
- Je veux pouvoir accéder à mes services en cours de développement par dns (exemple: http://mykillingapp.charloup.test)

**Solution retenue**
- Pour limiter le nombre de logiciels à installer, et permettre la possibilité de configurer facilement mon environnement, je vais donc déployer mon environnement de développement dans une machine virtuelle hyper-v à l'aide de Vagrant.
- Vu que je dois basculer rapidement d'une connexion wi-fi à une connexion ethernet, je ne choisirai pas de créer un switch hyper-v externe car ma machine virtuelle ne pourra pas avoir une ip statique.
- Je vais donc créer un switch hyper-v interne qui partagera sa connexion avec la connexion principale. De cette façon, ma machine virtuelle pourra avoir une IP statique dans le réseau créé  par ICS (Internet Connexion Sharing) - adresse en *192.168.137.*
- ma machine sera donc configuré par Vagrant avec une box genérique Debian9 et elle sera provisionnée par Ansible en mode local (je souhaite installer le moins possible de logiciel sur la machine hôte)
- La machine virtuelle aura des outils installés pour le développement (éditeur, git, docker et sa registry, un reverse proxy)
- J'utilise une registry docker avec son répertoire data mappé sur la machine hôte. De cette façon mes images docker seront déjà présentes si je détruis et reconstruis ma machine virtuelle
- Je mets en place traefik comme reverse proxy : cela me permet d'avoir accès à mes services de type web hébergés dans des containers docker via leur nom DNS
- Des montages réseau de type smb permettront de partager des fichiers entre la machine hôte et la machine virtuelle.
- J'utiliserai le plugin ProxyConf de vagrant pour gérer un proxy dans ma machine virtuelle si nécessaire
- J'utiliserai le plugin HostManager de vagrant pour tenir à jour le nom de mes services dans la machine hôte

---
**NB : la plateforme de développement étant sur Windows 10, les commandes seront à lancer avec un Powershell avec des droits d'administrateur.**

---

# Prérequis

- Un PC avec Windows 10, au moins 4 Go de mémoire et sur lequel on bénéficie des droits d'administrateur.
- On doit s'assurer que Hyper-V est activé :
 `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All`

  Remarque : un redémarrage sera peut-être nécessaire
- Mettre à jour la version de configuration des VMs Hyper-V
Pour faire fonctionner des machines virtuelles récentes dans Hyper-V, il faut s'assurer d'avoir une version de configuration des machines virtuelles au moins égale à 8.3.

 Pour connaître la version supportée :
 `Get-VMHostSupportedVersion -Default`

 Si c'est trop bas, c'est que la version de Windows n'est pas à jour. Il faut au moins installer la mise-à-jour 18.09 de Windows 10 (prévoir entre 1h et 2h pour cette mise-à-jour....)

- Avoir installé Vagrant à l'aide du paquet MSI récupéré sur le site officiel. Pour la dernière version (actuellement 2.2.4) en 64 bits c'est ici :
 https://releases.hashicorp.com/vagrant/2.2.4/vagrant_2.2.4_x86_64.msi

- Avoir récupérer les sources de ce projet sur gitlab :

# 0. Créer un fichier d'environnement powershell\.env.ps1
ce fichier doit être créé dans le même format que le fichier ` powershell\.env.ps1-example` avec les valeurs correspondant à son environnement.

# 1. Préparation d'Hyper-V
On lance le script : `.\powershell\prepare_hyperv.ps1`

Ce script permet :
- de s'assurer que le réseau utilisé par ICS aura bien une adresse en `192.168.137.0/24`
- de créer un switch interne Hyper-V avec le nom `Vagrant`
- de partager la connexion internet (défini par la variable d'environnement `$env:EXTERNAL_CONNECTION_NAME`) avec notre réseau interne dans lequel sera créé la machine virtuelle

# 2. Préparation de la machine virtuelle
On lance le script : `.\powershell\prepare_vm.ps1`

Ce script permet:
- d'installer le plugin ProxyConf de Vagrant
- d'installer le plugin HostManager de Vagrant
- de récupérer la box generic/debian9 pour le provider hyperv
- de lancer la machine via vagrant et de la configurer :
  - via le shell pour la résolution de nom
  - via ansible_local pour configurer le nom d'hôte, le fqdn, l'ip, le ntp, la locale, et installer git, des éditeurs de texte (vi, vim, nano) et docker
- de redémarrer la machine et de la provisionner avec les services suivants :
  - Registry Docker
  - Reverse proxy Traefik

# 3. Script à lancer en cas de modification de connexion internet et de proxy
Il faut changer dans le fichier `powershell\.env.ps1` les valeurs de `$env:EXTERNAL_CONNECTION_NAME`, `$env:MY_PROXY` et `$env:NO_PROXY_RULES`

On lance le script : `.\powershell\change_connection.ps1`

ce script va :
- modifier le partage de connexion internet
- démarrer la machine si elle n'est pas déjà lancée
- provisionner la machine avec les paramètres de proxy
- s'assurer que les services sont bien lancés
