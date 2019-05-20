#Requires -Version 3.0

function Create-VirtualSwitch {
<#
  .SYNOPSIS
    Création d'un switch virtuel
  .DESCRIPTION
    Create-VirtualSwitch est une fonction qui permet de créer un switch virtuel.
  .PARAMETER SwitchName
    Le nom du switch a créer
  .PARAMETER NATNetwork
    L'adresse du réseau
  .PARAMETER NATGateway
    L'adresse de la passerelle
  .PARAMETER NATPrefixLength
    Longueur du préfixe
  .EXAMPLE
    Create-VirtualSwitch -SwitchName 'aa' -NATNetwork '192.168.220.0' -NATGateway '192.168.220.1' -NATPrefixLength 24
  .INPUTS
    String
  .OUTPUTS
    String
  .NOTES
    Author:  Christophe BARRIERE
    Website: https://gitlab.com/charloup
#>

  [CmdletBinding()]

  PARAM (
    [Parameter(Mandatory=$true)][string]$SwitchName,
    [Parameter(Mandatory=$true)][string]$NATNetwork,
    [Parameter(Mandatory=$true)][string]$NATGateway,
    [Parameter(Mandatory=$true)][int]$NATPrefixLength
  )

  PROCESS {
    # Création d'un nouveau switch virtuel hyper-v de type interne avec le nom $SwitchName
    New-VMSwitch -SwitchName $SwitchName -SwitchType Internal | Out-Null

    $natswitch = Get-NetAdapter -Name "*$SwitchName*"

    # Création d'une NAT gateway dans l'interface du switch
    New-NetIPAddress -IPAddress $NATGateway -PrefixLength $NATPrefixLength -InterfaceIndex $natswitch.InterfaceIndex | Out-Null

    # Creation d'un reseau NAT
    New-NetNat -Name NATNetwork$SwitchName -InternalIPInterfaceAddressPrefix "$NATNetwork/$NATPrefixLength" | Out-Null

    Write-Output "Creation du switch OK"
  }
}
