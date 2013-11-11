###########################################################################################################
#                                                                                                         #
# File:          BackupIPConfig.ps1                                                                       #
#                                                                                                         #
# Purpose:       Script for managing ip configuration on remote hosts via wmi                             #
#                - read configuration from system and export to a csv or xml file                         #
#                - import from a csv or xml file and write configuration to system                        #
#                                                                                                         #
# Author:        Sven Sperner <cethss@gmail.com>                                                          #
#                                                                                                         #
# Last edited:   31.05.2012                                                                               #
#                                                                                                         #
# Requirements:  Microsoft Windows PowerShell 2.0 + enabled WMI on remote host                            #
#                                                                                                         #
# Usage:                                                                                                  #
#  PowerShell -command C:\{Path2Script}\BackupIPConfig.ps1                                                #
#                                                                                                         #
# Parameter:                                                                                              #
#  -command {read|write}              read & export OR import & write                                     #
#  -hosts {<list>|<listFile>}         comma separated list or a file with a host in each line             #
#  -backupFile <filename>             filename to save the settings in, without file extension            #
#  -fileType {csv|xml}                file type and extension for backupFile                              #
#                                                                                                         #
# Usage examples:                                                                                         #
#  PowerShell -command ".\BackupIPConfig.ps1 read -hosts hostList.txt -backupFile Saved2012 -fileType csv"#
#  --> read hosts from hostList.txt and save settings to Saved2012.csv                                    #
#  PowerShell -command ".\BackupIPConfig.ps1 read -hosts serverXY,horst0815,reschna007 -fileType xml"     #
#  --> read settings from the three hosts and save to <stdname>.xml (IPConfigList.xml)                    #
#  PowerShell -command ".\BackupIPConfig.ps1 write -backupFile Saved2012"                                 #
#  --> import from "Saved2012.csv" (csv is std) and write to every host where settings are present for    #
#                                                                                                         #
#                    This program is distributed in the hope that it will be useful,                      #
#                    but WITHOUT ANY WARRANTY; without even the implied warranty of                       #
#                    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                                 #
#                                                                                                         #
###########################################################################################################

PARAM(	$command="read",
		$hosts="localhost",
		$backupFile="IPConfigList",
		$fileType="csv",
		[Switch]$help	)


If( ($help) -OR (($fileType -ne "csv") -AND ($fileType -ne "xml")) )
{
	Write-Host "usage: $($MyInvocation.MYCommand) <read|write> <hostslist/-file> <backupfile> <csv|xml> [-help]"
	exit
}


# Resolve hostname <=> ip address
Function resolve( [String]$machine="localhost" )
{
	[System.Net.IPAddress]$IPobj = $null
	If( [System.Net.IPAddress]::tryparse($machine,[ref]$IPobj) -and $machine -eq $IPobj.tostring() )
	{
		$serv,$null,$null,$name,$null = nslookup $machine 2>$null
		$name = $name -replace "Name:\s+",""
		return $name
	}
	Else
	{
		$null,$serv,$null,$null,$ipadr = nslookup $machine 2>$null
		$ipadr = $ipadr -replace "Address:\s+",""
		return $ipadr
	}
}



# Read ip configuration from host ...
If( $command -eq "read" )
{
	If( Test-Path $hosts 2>&1 >$null )
	{	$hosts = Get-Content $hosts	}

	$confList = @()
	ForEach( $hostname in $hosts )
	{
		If( $hostname -eq "localhost" )
		{	$hostname = $(hostname)	}
		Write-Host "Getting ip configuration of $hostname"

		$netAdapters = Get-wmiobject -cl "Win32_NetworkAdapter" -comp $hostname -filter `
							"AdapterType = 'Ethernet 802.3' AND NetConnectionStatus = 2" #> 0"
		ForEach( $adapter in $netAdapters )
		{
			$adpConf = @($adapter.GetRelated('Win32_NetworkAdapterConfiguration'))[0]
			If( ($adpConf.IPEnabled) -and ($adpConf.IPAddress -ne "0.0.0.0") )
			{
				$confRow = "" | Select Hostname,Resolved,ConfType,AdpId,IPAddress,SubnetMask,Gateway,`
										Domain,DNS1,DNS2,DHCP,WINS1,WINS2
				$confRow.Hostname =		$hostname
				[System.Net.IPAddress]$IPobj = $null
				If( [System.Net.IPAddress]::tryparse($hostname,[ref]$IPobj) -and $hostname -eq $IPobj.tostring() )
				{	$confRow.Resolved =		[String]$(resolve("$hostname"))	}
				Else
				{	$confRow.Resolved =		[String]$(resolve("$hostname.$($adpConf.DNSDomain)"))	}
				If( $adpConf.DHCPEnabled )
				{	$confRow.ConfType =		"dynamic"	}
				Else
				{	$confRow.ConfType =		"static"	}
				$confRow.AdpId =		[String]$adapter.DeviceId
				$confRow.IPAddress =	[String]$adpConf.IPAddress
				$confRow.SubnetMask =	[String]$adpConf.IPSubnet
				$confRow.Gateway =		[String]$adpConf.DefaultIPGateway
				$confRow.Domain =		[String]$adpConf.DNSDomain
				If( $adpConf.DNSServerSearchOrder[0] )
				{	$confRow.DNS1 =			[String]$adpConf.DNSServerSearchOrder[0]	}
				Else
				{	$confRow.DNS1 =			[String]$adpConf.DNSServerSearchOrder		}
				If( $adpConf.DNSServerSearchOrder[1] )
				{	$confRow.DNS2 =			[String]$adpConf.DNSServerSearchOrder[1]	}
				Else
				{	$confRow.DNS2 =			""											}
				$confRow.DHCP =			[String]$adpConf.DHCPServer
				$confRow.WINS1 =		[String]$adpConf.WINSPrimaryServer
				$confRow.WINS2 =		[String]$adpConf.WINSSecondaryServer
				$confList += $confRow
			}
		}
	}
	# ... and export to csv file
	If( $confList.Length -gt 0 )
	{
		try{
			If( $fileType -eq "csv" )
			{	$confList | Export-Csv "$backupFile.$fileType" -noTypeInformation -Delimiter ";"	}
			ElseIf( $fileType -eq "xml" )
			{	$confList | Export-Clixml "$backupFile.$fileType"	}
			Write-Host "IP Configuration List exported to $backupFile.$fileType"
		}
		catch{
			Write-Error "$_`nCannot write to file $backupFile.$fileType"
			exit -1
		}
	}
}
# Import from csv file ...
ElseIf( $command -eq "write" )
{
	try{
		If( $fileType -eq "csv" )
		{	$confList = Import-Csv "$backupFile.$fileType" -Delimiter ";"	}
		ElseIf( $fileType -eq "xml" )
		{	$confList = Import-Clixml "$backupFile.$fileType"	}
		Write-Host "IP Configuration List imported from $backupFile.$fileType"
	}
	catch{
		Write-Error "$_`nCannot read from file $backupFile.$fileType"
		exit -1
	}
	# ... and write configuration to host
	ForEach( $confRow in $confList )
	{
		Write-Host "Setting ip configuration of $($confRow.Hostname)"

		$netAdapters = Get-wmiobject -cl "Win32_NetworkAdapter" -comp $confRow.Hostname -filter `
							"AdapterType = 'Ethernet 802.3' AND NetConnectionStatus = 2" #> 0"
		ForEach( $adapter in $netAdapters )
		{
			If( $adapter.DeviceId -eq $confRow.AdpId )
			{
				$adpConf = @($adapter.GetRelated('Win32_NetworkAdapterConfiguration'))[0]
				If( $confRow.ConfType -eq "static" )
				{
					try{	$adpConf.EnableStatic( $confRow.IPAddress, $confRow.SubnetMask ) > $null	}
					catch{	Write-Host "Could not write IP Address + Subnet Mask for $($confRow.Hostname)"	}
					try{	$adpConf.SetGateways( $confRow.Gateway ) > $null	}
					catch{	Write-Host "Could not write standard Gateway for $($confRow.Hostname)"	}
					try{	$adpConf.SetDNSDomain( $confRow.Domain ) > $null	}
					catch{	Write-Host "Could not write DNS Domain for $($confRow.Hostname)"	}
					try{	$adpConf.SetDNSServerSearchOrder( ($confRow.DNS1,$confRow.DNS2) ) > $null	}
					catch{	Write-Host "Could not write DNS Server(s) for $($confRow.Hostname)"	}
					try{	$adpConf.SetWINSServer( $confRow.WINS1, $confRow.WINS2 ) > $null	}
					catch{	Write-Host "Could not write WINS Server(s) for $($confRow.Hostname)"	}
				}
				ElseIf( $confRow.ConfType -eq "dynamic" )
				{
					try{	$adpConf.SetWINSServer( $confRow.WINS1, $confRow.WINS2 ) > $null	}
					catch{	Write-Host "Could not write WINS Server(s) for $($confRow.Hostname)"	}
					try{	$adpConf.EnableDHCP( ) > $null	}
					catch{	Write-Host "Could not enable DHCP for $($confRow.Hostname)"	}
					try{	$adpConf.SetDNSServerSearchOrder( ) > $null	}
					catch{	Write-Host "Could not write DNS Server(s) for $($confRow.Hostname)"	}
				}
				Else
				{
					Write-Host "$($confRow.Hostname) is configured $($confRow.ConfType)"
				}
			}
		}
	}
}
Else
{
	Write-Error "unknown command: $command"
	exit -1
}

