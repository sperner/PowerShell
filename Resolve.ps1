# Resolve domain name by ip-address or ip-address by domain name
# -> 'nslookup' is much faster than [System.Net.DNS]::GetHostEntry()
#

if( $($args.count) -lt 1 )
{
	Write-Host "usage: $($MyInvocation.MYCommand) <DomainName or IP-Address>"
	exit -1
}
else
{
	[System.Net.IPAddress]$IPobj = $null
	if( [System.Net.IPAddress]::tryparse($args[0],[ref]$IPobj) -and `
		$args[0] -eq $IPobj.tostring() )
	{
		Write-Host "Resolving IP-Address $($args[0]) to its associated DomainName"

		$serv,$null,$null,$name,$null = nslookup $($args[0]) 2>$null
		#$serv = $serv -replace "Server:\s+",""
		$name = $name -replace "Name:\s+",""

		Write-Host $name
	}
	else
	{
		Write-Host "Resolving DomainName $($args[0]) to its associated IP-Address"

		$null,$serv,$null,$null,$ipadr = nslookup $($args[0]) 2>$null
		#$serv = $serv -replace "Address:\s+",""
		$ipadr = $ipadr -replace "Address:\s+",""

		Write-Host $ipadr
	}
}