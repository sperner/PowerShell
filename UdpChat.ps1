# A simple .Net based UDP Chat
#

param( $address="Loopback", $lPort=2020, $rPort=2020 )


route print 0* |
%{ 
	if( $_ -match "\s{2,}0\.0\.0\.0" )
	{ 
		$null,$null,$null,$LocalIP,$null = [regex]::replace($_.trimstart(" "),"\s{2,}",",").split(",")
	}
}

try{
	$localEndpoint = new-object System.Net.IPEndPoint( [IPAddress]::Any, $lPort )
	$udpReceiver = new-object System.Net.Sockets.UdpClient $lPort

	$remoteEndpoint = new-object System.Net.IPEndPoint( [IPAddress]::$address, $rPort )
	$udpSender = new-object System.Net.Sockets.UdpClient
}
catch{
	throw $_
	exit -1
}

$data = ""
$dataReady = $false
while( $Host.UI.RawUi.KeyAvailable )
{	$Host.UI.RawUI.FlushInputBuffer()	}
Write-Host "Press ESC to stop the udp chat ..." -fore yellow
Write-Host ""
Write-Host -NoNewLine ":> "

while( $true )
{
	if( $Host.UI.RawUi.KeyAvailable )
	{
		$key = $Host.UI.RawUI.ReadKey( "NoEcho,IncludeKeyDown,IncludeKeyUp" )
		$Host.UI.RawUI.FlushInputBuffer()
		if( $key.VirtualKeyCode -eq 27 )
		{	break	}
		elseif( $key.VirtualKeyCode -eq 13 )
		{
			$dataReady = $true
			$null = $Host.UI.RawUI.ReadKey().Character
			$Host.UI.RawUI.FlushInputBuffer()
		}
		else
		{
			#$data += $key.Character
			$data += $Host.UI.RawUI.ReadKey().Character
			$Host.UI.RawUI.FlushInputBuffer()
		}
	}

	if( $udpReceiver.Available )
	{
		$content = $udpReceiver.Receive( [ref]$localEndpoint )
		Write-Host "`n$($localEndpoint.Address.IPAddressToString):$($localEndpoint.Port) $([Text.Encoding]::ASCII.GetString($content))"
		Write-Host -NoNewLine ":> "
	}

	if( $dataReady )
	{
		Write-Host -NoNewLine "`n:> "
		$bytes = [Text.Encoding]::ASCII.GetBytes( $data )
		$bytesSent = $udpSender.Send( $bytes, $bytes.length, $remoteEndpoint )
		$data = ""
		$dataReady = $false
	}
}

$udpSender.Close( )
$udpReceiver.Close( )
