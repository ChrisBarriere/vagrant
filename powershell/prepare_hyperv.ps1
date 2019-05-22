# dotsource du fichier avec les variables d'environnement
. $PSScriptRoot\.env.ps1

# dotsource de mes cmdlets powershell
. $PSScriptRoot\lib\manageSharingInternetConnection.ps1
. $PSScriptRoot\lib\createVirtualSwitch.ps1

# on s'assure que le réseau créé par Windows pour le partage de connexion internet aura une adresse en 192.168.137.0/24
Set-InternetConnectionSharingIPAddressRange -ScopeAddress '192.168.137.1'

# On crée le switch interne
Create-VirtualSwitch -SwitchName 'Vagrant' -NATNetwork '192.168.220.0' -NATGateway '192.168.220.1' -NATPrefixLength 24

# On active le partage de connexion internet
Enable-InternetConnectionSharing -InterfaceNameMaster $env:EXTERNAL_CONNECTION_NAME -InterfaceNameClient 'vEthernet (Vagrant)'
