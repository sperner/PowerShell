# A simple .Net based TCP Client
#

param( $data="empty", $address="Loopback", $port=2020 )


try{
	$endpoint = new-object System.Net.IPEndPoint( [IPAddress]::$address, $port )
	$udpclient = new-object System.Net.Sockets.UdpClient
}
catch{
	throw $_
	exit -1
}

$bytes = [Text.Encoding]::ASCII.GetBytes( $data )
$bytesSent = $udpclient.Send( $bytes, $bytes.length, $endpoint )

$udpclient.Close( )
