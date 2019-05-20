# dotsource du fichier avec les variables d'environnement
. $PSScriptRoot\.env.ps1

# dotsource de mes cmdlets powershell
. $PSScriptRoot\lib\manageSharingInternetConnection.ps1

# On active le partage de connexion internet
Enable-InternetConnectionSharing -InterfaceNameMaster $env:EXTERNAL_CONNECTION_NAME -InterfaceNameClient 'vEthernet (Vagrant)'

# On reprovisionne la machine pour le changement de proxy si nécessaire
if (vagrant status --machine-readable $env:VM_HYPERV_NAME | Select-String -Pattern ',state,off') {
  vagrant up --provision_with ansible_local_services
}
if (vagrant status --machine-readable $env:VM_HYPERV_NAME | Select-String -Pattern ',state,running') {
  vagrant provision --provision_with ansible_local_services
}
