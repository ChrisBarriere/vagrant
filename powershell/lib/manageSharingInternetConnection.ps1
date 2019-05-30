#Requires -Version 3.0

Function Set-InternetConnectionSharingIPAddressRange {
  <#
    .SYNOPSIS
      Mettre-à-jour l'adressage réseau du réseau bénéficant du partage de connexion Internet
    .DESCRIPTION
      Set-InternetConnectionSharingIPAddressRange est une fonction qui permet de mettre-à-jour l'adressage réseau du réseau bénéficant du partage de connexion Internet.
    .PARAMETER ScopeAddress
      La valeur de la première addresse à utiliser
    .EXAMPLE
      Set-InternetConnectionSharingIPAddressRange -ScopeAddress '192.168.137.1'
    .INPUTS
      String
    .NOTES
      Author:  Christophe BARRIERE
      Website: https://gitlab.com/charloup
  #>

  [CmdletBinding()]

  PARAM (
    [Parameter(Mandatory)]
    [string[]]$ScopeAddress
  )

  PROCESS {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters" -Name ScopeAddress -Value $ScopeAddress
  }
}

Function Get-InternetConnectionSharingConfiguration {
  <#
    .SYNOPSIS
      Récupérer la configuration du partage de connexion internet pour les cartes réseau spécifiées.
    .DESCRIPTION
      Get-InternetConnectionSharingConfiguration est une fonction qui permet de récupérer la configuration du partage de connexion internet pour les cartes réseau spécifiées.
    .PARAMETER InterfaceNames
      Les noms des cartes réseau dont il faut récupérer le status
    .EXAMPLE
      Get-InternetConnectionSharingConfiguration -InterfaceNames 'My Enterprise Network', 'Wi-fi', 'Internal Virtual Switch'
    .EXAMPLE
      'My Enterprise Network', 'Wi-fi', 'Internal Virtual Switch' | Get-InternetConnectionSharingConfiguration
    .EXAMPLE
      Get-NetAdapter | Get-InternetConnectionSharingConfiguration
    .INPUTS
      String
    .OUTPUTS
      PSCustomObject
    .NOTES
      Author:  Christophe BARRIERE
      Website: https://gitlab.com/charloup
  #>

  [CmdletBinding()]

  PARAM (
    [Parameter(Mandatory,
               ValueFromPipeline,
               ValueFromPipelineByPropertyName)]
    [Alias('Name')]
    [string[]]$InterfaceNames
  )

  BEGIN {
    $netShare = $null
    try
      {
        # Creation d'un objet NetSharingManager
        $netShare = New-Object -ComObject HNetCfg.HNetShare
      }
      catch
      {
        # Enregistrement de la librairie HNetCfg library (une seule fois)
        regsvr32 /s hnetcfg.dll
        # Creation d'un objet NetSharingManager
        $netShare = New-Object -ComObject HNetCfg.HNetShare
      }
  }

  PROCESS {
    foreach ($Interface in $InterfaceNames) {
      # Recherche d'une connexion pour la carte réseau
      $connection = $netShare.EnumEveryConnection | Where-Object { $netShare.NetConnectionProps.Invoke($_).Name -eq $Interface }
      try {
        # Récupération de la configuration de partage de connexion internet pour la carte réseau
        $configuration = $netShare.INetSharingConfigurationForINetConnection.Invoke($connection)
      }
      catch {
        # Si erreur affichage d'un message d'erreur et passage à la carte réseau suivante
        Write-Warning -Message "Impossible de récupérer la configuration du partage de connexion internet pour la carte réseau: '$Interface'"
        Continue
      }
      # Ajout de la configuration à l'objet de retour de fonction
      [pscustomobject]@{
        Name = $Interface
        SharingEnabled = $configuration.SharingEnabled
        SharingConnectionType = $configuration.SharingConnectionType
        InternetFirewallEnabled = $configuration.InternetFirewallEnabled
      }
    }
  }
}

Function Disable-InternetConnectionSharing {
  <#
    .SYNOPSIS
      Désactiver le partage de connexion internet entre deux cartes réseau.
    .DESCRIPTION
      Disable-InternetConnectionSharing est une fonction qui permet de désactiver le partage de connexion internet entre deux cartes réseau.
    .PARAMETER InterfaceNameMaster
      Le nom de la carte réseau qui est partagée
    .PARAMETER InterfaceNameClient
      Le nom de la carte réseau qui utilise le partage
    .EXAMPLE
      Disable-InternetConnectionSharing -InterfaceNameMaster 'Wi-fi' -InterfaceNameClient 'Internal Virtual Switch'
    .NOTES
      Author:  Christophe BARRIERE
      Website: https://gitlab.com/charloup
  #>

  [CmdletBinding()]

  PARAM (
    [Parameter(Mandatory)]
    [string]$InterfaceNameMaster,
    [Parameter(Mandatory)]
    [string]$InterfaceNameClient
  )

  BEGIN {
    # Vérification que la carte réseau master existe et est activée
    Get-NetAdapter -Name $InterfaceNameMaster -ErrorAction SilentlyContinue -OutVariable nicmaster | Out-Null
    If (($nicmaster.count -eq 0) -or ($nicmaster.Status -eq 'Disabled') -or ($nicmaster.Status -eq 'Not Present')) {
      Write-Warning "$InterfaceNameMaster n'est pas une carte réseau valide ou n'est pas activée."
      Break
    }

    # récupération de la configuration de partage de la carte réseau master
    $configurationResultMaster = $nicmaster.Name | Get-InternetConnectionSharingConfiguration

    # Vérification que la carte réseau master est activée pour le partage de connexion internet
    if ($configurationResultMaster.sharingEnabled -contains $false) {
      Write-Warning -Message "Le partage de connexion internet n'est pas activée sur $InterfaceNameMaster"
      Break
    }

    # Vérification que la carte réseau master partage la connexion internet
    if ($configurationResultMaster.SharingConnectionType -contains 1) {
      Write-Warning -Message "$InterfaceNameMaster ne partage pas sa connexion internet"
      Break
    }

    # Vérification que la carte réseau client existe et est activée
    Get-NetAdapter -Name $InterfaceNameClient -ErrorAction SilentlyContinue -OutVariable nicclient | Out-Null
    If (($nicclient.count -eq 0) -or ($nicclient.Status -eq 'Disabled') -or ($nicclient.Status -eq 'Not Present')) {
      Write-Warning "$InterfaceNameClient n'est pas une carte réseau valide ou n'est pas activée."
      Break
    }

    # récupération de la configuration de partage de la carte réseau client
    $configurationResultClient = $nicclient.Name | Get-InternetConnectionSharingConfiguration

    # Vérification que la carte réseau client est activée pour le partage de connexion internet
    if ($configurationResultClient.sharingEnabled -contains $false) {
      Write-Warning -Message "Le partage de connexion internet n'est pas activée sur $InterfaceNameClient"
      Break
    }

    # Vérification que la carte réseau client utilise le partage de la connexion internet
    if ($configurationResultClient.SharingConnectionType -contains 0) {
      Write-Warning -Message "$InterfaceNameClient n'utilise pas le partage de connexion internet"
      Break
    }

    # On peut continuer
    $netShare = $null
    try
      {
        # Creation d'un objet NetSharingManager
        $netShare = New-Object -ComObject HNetCfg.HNetShare
      }
      catch
      {
        # Enregistrement de la librairie HNetCfg library (une seule fois)
        regsvr32 /s hnetcfg.dll
        # Creation d'un objet NetSharingManager
        $netShare = New-Object -ComObject HNetCfg.HNetShare
      }
  }

  PROCESS {
    # Récupération de la connexion master
    $connectionMaster = $netShare.EnumEveryConnection | Where-Object { $netShare.NetConnectionProps.Invoke($_).Name -eq $InterfaceNameMaster }
    # Récupération de la configuration de partage du master
    $configurationMaster = $netShare.INetSharingConfigurationForINetConnection.Invoke($connectionMaster)
    # Désactivation du partage dans la configuration du master
    $configurationMaster.DisableSharing()

    # Récupération de la connexion client
    $connectionClient = $netShare.EnumEveryConnection | Where-Object { $netShare.NetConnectionProps.Invoke($_).Name -eq $InterfaceNameClient }
    # Récupération de la configuration de partage du client
    $configurationClient = $netShare.INetSharingConfigurationForINetConnection.Invoke($connectionClient)
    # Désactivation du partage dans la configuration du client
    $configurationClient.DisableSharing()

    Write-Output "le partage de connexion a été désactivé entre $InterfaceNameMaster et $InterfaceNameClient"
  }
}

Function Enable-InternetConnectionSharing {
  <#
    .SYNOPSIS
      Activer le partage de connexion internet entre deux cartes réseau.
    .DESCRIPTION
      Enable-InternetConnectionSharing est une fonction qui permet d'activer le partage de connexion internet entre deux carteq réseau.
    .PARAMETER InterfaceNameMaster
      Le nom de la carte réseau qui doit partager la connexion internet
    .PARAMETER InterfaceNameClient
      Le nom de la carte réseau qui doit utiliser le partage de connexion internet
    .EXAMPLE
      Enable-InternetConnectionSharing -InterfaceNameMaster 'Wi-fi' -InterfaceNameClient 'Internal Virtual Switch'
    .EXAMPLE
    .NOTES
      Author:  Christophe BARRIERE
      Website: https://gitlab.com/charloup
  #>

  [CmdletBinding()]

  PARAM (
    [Parameter(Mandatory)]
    [string]$InterfaceNameMaster,
    [Parameter(Mandatory)]
    [string]$InterfaceNameClient
  )


  # Vérification que la carte réseau master existe et est activée
  Get-NetAdapter -Name $InterfaceNameMaster -ErrorAction SilentlyContinue -OutVariable nicmaster | Out-Null
  If (($nicmaster.count -eq 0) -or ($nicmaster.Status -eq 'Disabled') -or ($nicmaster.Status -eq 'Not Present')) {
    Write-Warning "$InterfaceNameMaster n'est pas une carte réseau valide ou n'est pas activée."
    Break
  }

  # Vérification que la carte réseau client existe et est activée
  Get-NetAdapter -Name $InterfaceNameClient -ErrorAction SilentlyContinue -OutVariable nicclient | Out-Null
  If (($nicclient.count -eq 0) -or ($nicclient.Status -eq 'Disabled') -or ($nicclient.Status -eq 'Not Present')) {
    Write-Warning "$InterfaceNameClient n'est pas une carte réseau valide ou n'est pas activée."
    Break
  }

  # On désactive eventuellement un partage existant
  $configurationResult = Get-NetAdapter | Get-InternetConnectionSharingConfiguration
  if ($configurationResult.SharingEnabled -contains $true) {
    $actualMaster = $configurationResult | where { ($_.SharingEnabled -eq $true) -and ($_.SharingConnectionType -eq 0) }
    $actualMasterName = $actualMaster.Name
    $actualClient = $configurationResult | where { ($_.SharingEnabled -eq $true) -and ($_.SharingConnectionType -eq 1) }
    $actualClientName = $actualClient.Name
    if (($actualMasterName -eq $InterfaceNameMaster) -and ($actualClientName -eq $InterfaceNameClient)) {
      Write-Warning "Le partage entre $actualMasterName et $actualClientName est déjà activé."
      return
    }

    else {
      if ($actualClientName) {
        Disable-InternetConnectionSharing -InterfaceNameMaster $actualMasterName -InterfaceNameClient $actualClientName
      }
    }
  }

  # On peut continuer
  $netShare = $null
  try
  {
    # Creation d'un objet NetSharingManager
    $netShare = New-Object -ComObject HNetCfg.HNetShare
  }
  catch
  {
    # Enregistrement de la librairie HNetCfg library (une seule fois)
    regsvr32 /s hnetcfg.dll
    # Creation d'un objet NetSharingManager
    $netShare = New-Object -ComObject HNetCfg.HNetShare
  }

  # Récupération de la connexion master
  $connectionMaster = $netShare.EnumEveryConnection | Where-Object { $netShare.NetConnectionProps.Invoke($_).Name -eq $InterfaceNameMaster }
  # Récupération de la configuration de partage du master
  $configurationMaster = $netShare.INetSharingConfigurationForINetConnection.Invoke($connectionMaster)
  # Activation du partage en tant que master
  $configurationMaster.EnableSharing(0)

  # Récupération de la connexion client
  $connectionClient = $netShare.EnumEveryConnection | Where-Object { $netShare.NetConnectionProps.Invoke($_).Name -eq $InterfaceNameClient }
  # Récupération de la configuration de partage du client
  $configurationClient = $netShare.INetSharingConfigurationForINetConnection.Invoke($connectionClient)
  # Activation du partage en tant que client
  $configurationClient.EnableSharing(1)
  Write-Output "le partage de connexion a été activé entre $InterfaceNameMaster et $InterfaceNameClient"
}
