# Modifying IPs
#

param( [parameter(Mandatory=$true)][String]$address, [int]$oktett=4, [parameter(Mandatory=$true)][int]$newVal, [switch]$Help )

if( $Help )
{
	Write-Host "usage: $($MyInvocation.MYCommand) -address <IP-Address> [-oktett <Oktett2change=4>] -newVal <newValue> [-help]"
	exit -1
}

$ip4change = $address.split(".")

if( $ip4change.count -lt 4 )
{
	Write-Host "Not a valid IP-Address - to short"
	exit -1
}
elseif( $ip4change.count -gt 4 )
{
	Write-Host "Not a valid IP-Address - to long"
	exit -1
}

$ip4change[$oktett-1] = $newVal
$newIP = $ip4change -join "." 
Write-Host $newIP