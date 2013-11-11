# A .Net based PowerShell packet generator
#
# Test if WinVersion supports raw sockets: netsh winsock show catalog
# -->> RAW/IP or RAW/IPv6
# HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Afd\Parameters\DisableRawSecurity
# -->> set to 1 to allow non admin users use raw sockets
#


function packet()
{
	route print 0* |
	%{ 
		if( $_ -match "\s{2,}0\.0\.0\.0" )
		{ 
			$null,$null,$null,$LocalIP,$null = [regex]::replace($_.trimstart(" "),"\s{2,}",",").split(",")
		}
	}
	Write-Host "got ip address: $LocalIP"

	$stringToSend = "just a test - nothing coming along?"
#	$encoding = [system.Text.Encoding]::UTF8
#	[Byte[]] $bytesToSent = (0..19)
#	$bytesToSent[0] = 4 + 64	#ver=4 + ihl=4(bit7)
#	$bytesToSent[1] = 0			#tos
#	$bytesToSent[2] = 0			#totLength
#	$bytesToSent[3] = 20 #31		#totLength
#	$bytesToSent[4] = 0			#ident
#	$bytesToSent[5] = 0			#ident
#	$bytesToSent[6] = 0			#flags+frag
#	$bytesToSent[7] = 0			#fragoff
#	$bytesToSent[8] = 100		#ttl
#	$bytesToSent[9] = 17		#proto
#	$bytesToSent[10] = 0		#hchk
#	$bytesToSent[11] = 0		#hchk
#	$bytesToSent[12] = 18		#src
#	$bytesToSent[13] = 14		#src
#	$bytesToSent[14] = 25		#src
#	$bytesToSent[15] = 172		#src
#	$bytesToSent[16] = 255		#dst
#	$bytesToSent[17] = 255		#dst
#	$bytesToSent[18] = 255		#dst
#	$bytesToSent[19] = 255		#dst
#	#$bytesToSent += $encoding.GetBytes( $stringToSend )
#	[Byte[]] $ipHeader = (
#		0x45, 0x00, 0x00, 0x30, 0x28, 0xC0, 0x40, 0x11, 0x80, 0x06,
#		0x6F, 0x36, 0x55, 0x42, 0xDE, 0x28, 0x55, 0x42, 0xDE, 0x27
#		)
#	$bytesToSent = $ipHeader
	$bytesToSent = [Text.Encoding]::ASCII.GetBytes( $stringToSend )
	Write-Host "got byte-array"
			
#	try {
		$Socket = New-Object Net.Sockets.Socket( [Net.Sockets.AddressFamily]::InterNetwork, `
												[Net.Sockets.SocketType]::Raw, `
												[Net.Sockets.ProtocolType]::Raw )
		Write-Host "got socket"

		#SetSocketOption( {Socket,IP,IPv6,Tcp,Udp}, {...}, {[bool],[int32],...]} )
		# only over raw ndis driver - searching for a way to use from powershell...
		#$Socket.SetSocketOption( "IP", "HeaderIncluded", $true )
		#Write-Host "set options"

		#$Socket.ReceiveBufferSize = 1024000
		#Write-Host "set receive buffersize"
		$Socket.SendBufferSize = 1024
		Write-Host "set send buffersize"

		#$Endpoint = New-Object Net.IPEndpoint( [Net.IPAddress]"$LocalIP", 1000 )
		$Destpoint = New-Object Net.IPEndpoint( [Net.IPAddress]"192.168.0.1", 1000 )
		Write-Host "got endpoints"

		#$Socket.Bind( $Endpoint )
		#Write-Host "bound endpoint"
		#$Socket.Connect( $Destpoint )
		#Write-Host "connected socket"

		#$Socket.sendTo( $bytesToSent, $Endpoint )
		#Write-Host "Sent packet to $LocalIP"
		$Socket.sendTo( $bytesToSent, $Destpoint )
		Write-Host "Sent packet"

		#$Socket.disConnect( $Destpoint )
		$Socket.close( )
#	}catch{
#		Write-Host $_.Exception.ToString()
#	}
}
packet

function WakeOnLan( [Byte[]] $mac)
{
	$client = New-Object System.Net.Sockets.UdpClient
	$client.Connect( "255.255.255.255", 40000 )
	[Byte[]] $packet = new-object 'object[,]' 17,6

	for( $i = 0; $i -lt 6; $i++ )
	{	$packet[$i] = 0xFF	}
	for( $i = 1; $i -le 16; $i++ )
	{
		for( $j = 0; $j -lt 6; $j++ )
		{	$packet[$i*6 + $j] = $mac[$j]	}
	}
	$client.Send($packet, $packet.Length)
	$client.Close
}
#wakeonlan 0x53,0x73,0x53,0x73,0x53,0x73

function udppacket( [String]$ipaddress="127.0.0.1", [int]$port=50000, [String]$payload="empty" )
{
	$client = New-Object System.Net.Sockets.UdpClient
	$client.Connect( "$ipaddress", $port )
	[Byte[]] $packet = [Text.Encoding]::ASCII.GetBytes( $payload )
	$client.Send($packet, $packet.Length)
	$client.Close()
}
#udppacket -ipaddress 192.168.0.1 -payload "dies ist ein test"

function tcppacket( [String]$ipaddress="127.0.0.1", [int]$port=50000, [String]$payload="empty" )
{
	$client = New-Object System.Net.Sockets.TcpClient
	$client.Connect( "$ipaddress", $port )
	[Byte[]] $packet = [Text.Encoding]::ASCII.GetBytes( $payload )
	$client.Send($packet, $packet.Length)
	$client.Close()
}
#tcppacket -ipaddress 192.168.0.1 -payload "dies ist ein test"



