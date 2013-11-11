# Get network informations of a (remote) host
#

if( $args[0] )
{
	$hostname = $args[0]
}
else
{
	$hostname = "localhost"
}
 

$netAdapters = Get-wmiobject -cl "Win32_NetworkAdapter" -comp $hostname -filter `
		"AdapterType = 'Ethernet 802.3' AND NetConnectionStatus = 2" #> 0"

if( $netAdapters )
{
	Write-Output "------------------------------------"
	Write-Output "| Machine:`t	$hostname"
	Write-Output "------------------------------------"
	ForEach( $adapter in $netAdapters )
	{
		$adpConf = @($adapter.GetRelated('Win32_NetworkAdapterConfiguration'))[0]
		Write-Output ""
		Write-Output "DeviceID:`t`t$($adapter.DeviceID)"
		Write-Output "Manufacturer:`t`t$($adapter.Manufacturer)"
		Write-Output "Name:`t`t`t$($adapter.Name)"
		Write-Output "Adapter Type:`t`t$($adapter.AdapterType)"
		Write-Output "Service Name:`t`t$($adapter.ServiceName)"
		Write-Output "DNS HostName:`t`t$($adpConf.DNSHostName)"
		Write-Output "MAC Address:`t`t$($adpConf.MACAddress)"
		if( $adpConf.IPEnabled )
		{
			Write-Output "IP Address:`t`t$($adpConf.IPAddress)"
			Write-Output "Subnet Mask:`t`t$($adpConf.IPSubnet)"
			Write-Output "Default Gateway:`t$($adpConf.DefaultIPGateway)"
			Write-Output "DNS Domain:`t`t$($adpConf.DNSDomain)"
			Write-Output "DNS Server:`t`t$($adpConf.DNSServerSearchOrder)"
			Write-Output "WINS primary:`t`t$($adpConf.WINSPrimaryServer)"
			Write-Output "WINS secondary:`t`t$($adpConf.WINSSecondaryServer)"
		}
		if( $adpConf.DHCPEnabled -and $adpConf.DHCPLeaseObtained )
		{
			Write-Output "DHCP Lease Obtained:`t$($adpConf.ConvertToDateTime( $adpConf.DHCPLeaseObtained ))"
			Write-Output "DHCP Lease Expires:`t$($adpConf.ConvertToDateTime( $adpConf.DHCPLeaseExpires ))"
			Write-Output "DHCP Server:`t`t$($adpConf.DHCPServer)"
		}
		if( $adpConf.IPXEnabled )
		{
			Write-Output "IPX Address:`t`t$($adpConf.IPXAddress)"
			Write-Output "IPX Frame Type:`t`t$($adpConf.IPXFrameType)"
			Write-Output "IPX Media Type:`t`t$($adpConf.IPXMediaType)"
			Write-Output "IPX Network Number:`t$($adpConf.IPXNetworkNumber)"
			Write-Output "IPX VirtualNetNumber:`t$($adpConf.IPXVirtualNetNumber)"
		}
		Write-Output "--------------------------------------------"
	}
}
