# A simple (and for a PowerShell one, really fast!) IP portscanner
# no param for usage
#

# Connection wait time
$waitTime = 50

# Process given parameters...
if( $($args.count) -lt 1 )		# no parameter given, print usage:
{
	Write-Host "usage: $($MyInvocation.MYCommand) <IP-Address> [<Start-Port> <End-Port>]"
	exit -1
}
elseif( $($args.count) -lt 3 )	# only hostname or ip-address was given
{								# ...scanning complete portrange:
	$target = $args[0]
	$portStart = 1
	$portEnd = 65535
}
else							# all parameters given:
{
	$target = $args[0]
	$portStart = $args[1]
	$portEnd = $args[2]
}

# Built-In error-handling: 'Continue' (default), 'SilentlyContinue', 'Inquire' or 'Stop'
$ErrorActionPreference = "SilentlyContinue"

# Check if the host is up
$ping = new-object System.Net.NetworkInformation.Ping
try
{
	$pingResult = $ping.send( $target )
	Write-Host "Host: $target"
	Write-Host ""
}
catch
{
	Write-Host "Error connecting to host $target"
	exit -1
}


# Read "services" file
$servicesFilePath = "$env:windir\System32\drivers\etc\services"            
# <service name>  <port number>/<protocol>  [aliases...]   [#<comment>]            
$serviceFile = [IO.File]::ReadAllText("$env:windir\System32\drivers\etc\services") -split
# filter out all comment lines
([Environment]::NewLine) -notlike "#*"

# Read protocols from services
Function getService( $port )
{
	$protocols = foreach( $line in $serviceFile )
	{            
		# not empty lines
		if( -not $line )	{ continue }

		# split lines into name, port+proto, alias+comment
		$serviceName, $portAndProtocol, $aliasesAndComments = $line.Split(' ', [StringSplitOptions]'RemoveEmptyEntries')
		# split port+proto into port, proto
		$portNumber, $protocolName = $portAndProtocol.Split("/")            

		if( $portNumber -eq $port )
		{
			return $serviceName
		}
	}
}


Write-Host "Press ESC to stop the port scanner ..." -fore yellow
Write-Host ""
if( $pingResult.status.tostring() –eq “Success” )
{
	# Host is up and ping succeeded...
	Write-Host "Scanning ports:"

	# Begin port-scanning...
	foreach( $port in $portStart..$portEnd  )
	{
		# when a key was pressed...
		if( $host.ui.RawUi.KeyAvailable )
		{
			$key = $host.ui.RawUI.ReadKey( "NoEcho,IncludeKeyUp,IncludeKeyDown" )
			# if ESC was pressed, stop sniffing
			if( $key.VirtualKeyCode -eq 27 )
			{
				break
			}
		}

		# Create a socket for test/scan
		$socket = new-object System.Net.Sockets.TcpClient
		# Connect to port (only begin the connection - faster!)
		$connection = $socket.BeginConnect( $target, $port, $null, $null )
		# Quit connection after (short) timeout
		$timeout = $Connection.AsyncWaitHandle.WaitOne( $waitTime, $false )
		if( !$timeout )
		{
			# Timeout: port is closed or response takes to long
			$socket.Close( )
			Write-Host "`r$port" -ForegroundColor Red -NoNewline
		}
		else
		{
			try
			{
				$socket.EndConnect( $connection )
				$socket.Close( )
				# Established connection closed: port is open
				Write-Host "`r$port <$(getService($port))> is open!"-foregroundcolor Green
				$socket = $null
			}
			catch
			{
				# No active connection to be closed: port is closed
				Write-Host "`r$port" -ForegroundColor Red -NoNewline
				$socket = $null
			}
		}
		# What about a progress-bar?
		#Write-Progress -activity "Scanning $($portEnd-$portStart) ports on $target" `
		#-status "*" -PercentComplete( (($port-$portStart) / ($portEnd-$portStart))  * 100 )
	}
	Write-Host "`r      "
}
else
{
	# Host, or device on route to host, is up but ping failed...
	Write-Host "Host at $target is down" -ForegroundColor Red
}
