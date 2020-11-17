$Adapters = (Get-NetAdapter).Name | sort

foreach ($Adapter in $Adapters) {
    Set-NetAdapterBinding -Name "$Adapter" -ComponentID "ms_tcpip6" -Enable $false
}