# some functions for powershell
# -->> to be dot sourced
#
# Windows (PowerShell) Profiles:
# %windir%\system32\WindowsPowerShell\v1.0\profile.ps1							-> all users, all shells
# %windir%\system32\WindowsPowerShell\v1.0\ Microsoft.PowerShell_profile.ps1	-> all users, only powershell
# %UserProfile%\My Documents\WindowsPowerShell\profile.ps1						-> current user, all shells
# %UserProfile%\My Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1	-> current user, only powershell
#


# already built-in:
#------------------
Set-Alias copy2clip $env:SystemRoot\system32\clip.exe
Set-Alias getAlias Get-Alias
#$(_Set-Function) getAssemblies
#$(_Set-Function) getCmdlets
#$(_Set-Function) getFunctions
#get.NetFunctions
#$(_Set-Function) getSpecialFolders
Set-Alias getVariables Get-Variable
#$(_Set-Function) getWmiNamespaces
#$(_Set-Function) loadAssembly
#$(_Set-Function) loadCsharp
#$(_Set-Function) notify
#$(_Set-Function) path
#$(_Set-Function) prompt

#$(_Set-Function) changeFileTimes
#$(_Set-Function) hexdump
#$(_Set-Function) play
#$(_Set-Function) speak

#$(_Set-Function) getLocalIP
#$(_Set-Function) getStandardGateway
#$(_Set-Function) netTraffic
#$(_Set-Function) resolve

#$(_Set-Function) getWeather
#$(_Set-Function) sendFax
#$(_Set-Function) sendSms
#$(_Set-Function) translate



## Environment
Function collect( )
{
<#	.SYNOPSIS
		Run garbage collector
#>
	[System.GC]::Collect()
}

Function getAssemblies( )
{
<#	.SYNOPSIS
		Get actual loaded assemblies
#>
	[appdomain]::CurrentDomain.GetAssemblies()
}

Function getCmdlets( )
{
<#	.SYNOPSIS
		Get available cmdlets
#>
	Get-Command -CommandType cmdlet
}

Function getEventLog( $address="127.0.0.1" )
{
<#	.SYNOPSIS
		Get event log of a machine
#>
	$(New-Object -TypeName System.Diagnostics.EventLog Application,$address).Entries
}

Function getFunctions( )
{
<#	.SYNOPSIS
		Get available functions
#>
	Get-Command -CommandType function
}

Function get.NetFunctions( [Switch]$static )
{
<#	.SYNOPSIS
		Get available .net functions
	.DESCRIPTION
		~5267 static, ~131819 overall
	.PARAMETER static
		Show only static elements
#>
	if( !$static )
	{	[AppDomain]::CurrentDomain.GetAssemblies() | foreach { $_.GetTypes() } | foreach { $_.GetMethods() } | select DeclaringType, Name -unique | sort DeclaringType, Name	}
	else
	{	[AppDomain]::CurrentDomain.GetAssemblies() | foreach { $_.GetTypes() } | foreach { $_.GetMethods() } | where { $_.IsStatic } | select DeclaringType, Name -unique | sort DeclaringType, Name	}
}

Function getSpecialFolders( )
{
<#	.SYNOPSIS
		Get windows special folders
#>
	[enum]::GetValues( [System.Environment+SpecialFolder] ) |
	%{	"$_ maps to " + [System.Environment]::GetFolderPath( $_ )	}
}

Function getWmiNamespaces( )
{
<#	.SYNOPSIS
		Get WMI namespaces
#>
	Get-WMIObject -Query "Select * from __Namespace" -Namespace Root | Select-Object Name
}

Function loadAssembly( [String]$path, [Switch]$all )
{
<#	.SYNOPSIS
		Get windows special folders
	.EXAMPLE
		PS> loadAssembly System.Net
#>
	if( $all )
	{
		foreach( $file in $(Get-ChildItem "C:\WIN\Microsoft.NET\Framework\v*\*.dll") )
		{	[System.Reflection.Assembly]::LoadFile("$file") 2>$null	}
	}
	else
	{	[System.Reflection.Assembly]::LoadWithPartialName("$path")	}
}

Function loadCsharp( $code, $file )
{
<#	.SYNOPSIS
		Load C# code -> use with: [class]::method
#>
	if( $file )
	{	Add-Type –Path "$file"	}
	else
	{
#		Add-Type -TypeDefinition @{
#								"$code"
#								}@
	}
}

Function notify( [String]$text="no text was passed", [String]$title="For your interest", `
				[String]$icon="$env:windir\CmdFSC\nobugs.ico", [String]$bticon="Info", $time=10000 )
{
<#	.SYNOPSIS
		Show notification
	.PARAMETER bticon
		Info|Warning|Error
#>
	[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
	$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon 
	$objNotifyIcon.Icon = "$icon"
	$objNotifyIcon.BalloonTipIcon = "$bticon" 
	$objNotifyIcon.BalloonTipText = "$text" 
	$objNotifyIcon.BalloonTipTitle = "$title" 
	$objNotifyIcon.Visible = $True 
	$objNotifyIcon.ShowBalloonTip( $time )
}

Function path( [String]$path, [Switch]$first )
{
<#	.SYNOPSIS
		Add folder to $path
	.PARAMETER first
		Add the new path as first element
#>
	if( $path )
	{
		if( Test-Path $path )
		{	
			if( $first )
			{	Set-Item -path Env:Path -value ("$($path);" + $Env:Path)	}
			else
			{	Set-Item -path Env:Path -value ($Env:Path + ";$path")	}
		}
	}
	else
	{	(Get-ChildItem Env:\Path).Value	}
}

Function prompt()
{
<#	.SYNOPSIS
		Custom prompt
	.DESCRIPTION
		[USER]@[HOST] [PATH]>
#>
	$identity = [Security.Principal.WindowsIdentity]::GetCurrent( )
	$principal = [Security.Principal.WindowsPrincipal] $identity
	if( $principal.IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator") )
	{ $usercolor = "Blue" }
	else
	{ $usercolor = "Green" }
	$location = Get-Location
	if( $location.Path.Length -gt 30 )
	{	$location = "...\$($location.Path.Split("\").Get( $location.Path.Split("\").count-1 ))"	}
	Write-Host -NoNewLine -ForegroundColor $usercolor "$Env:USERNAME"
	Write-Host -NoNewLine -ForegroundColor Gray "@"
	Write-Host -NoNewLine -ForegroundColor Green "$Env:COMPUTERNAME "
	Write-Host -NoNewLine -ForegroundColor Gray $location
	if (test-path variable:/PSDebugContext)
	{ Write-Host -NoNewLine '[DBG]: ' }
	if($NestedPromptLevel -ge 1)
	{ Write-Host -NoNewLine '>>' } 
	Write-Host -NoNewLine '>'
	return " "
}



## Files & folders
Function changeFileTimes( [String]$path, [String]$date, [Switch]$creation=$false, `
							[Switch]$lastWrite=$false, [Switch]$lastAccess=$false  )
{
<#	.SYNOPSIS
		Change the times of a file or folder
	.EXAMPLE
		PS> changeFileTimes <file/folder> <'01/01/1900 0:00 AM'> -creation
	.EXAMPLE
		PS> changeFileTimes <file/folder> <01/01/1900> -lastWrite -lastAccess
	.EXAMPLE
		PS> changeFileTimes <file/folder> <0:00> -{creation,lastWrite,lastAccess}
#>
	if( !$path -or !$date )
	{	exit -1	}
	if( $(Test-Path $path) )
	{	$item = Get-Item $path	}
	else
	{	Write-Host "File or Folder $path not present"; exit -1	}
	if( $(Get-Date $date) )
	{
		if( $creation )
		{	$item.CreationTime = Get-Date $date	}
		if( $lastWrite )
		{	$item.LastWriteTime = Get-Date $date	}
		if( $lastAccess )
		{	$item.LastAccessTime = Get-Date $date	}
	}
	else
	{	Write-Host "$date is not a valid date and/or time"; exit -1	}
	$item
}

Function hexdump( $path, $width=16, $bytes=-1 )
{
<#	.SYNOPSIS
		Dump a files content in hex format
#>
	$OFS=""
	if( !(Test-Path $path) )
	{	Write-Host "no file at $path";	exit -1	}
	if( $bytes -eq -1 )
	{	$bytes = (Get-Item $path).length	}
	ForEach( $byte in Get-Content -Encoding byte $path -ReadCount $width -totalcount $bytes )
	{
		if( ($byte -eq 0).count -ne $width )
		{
			$hex = $byte | Foreach-Object {	" " + ("{0:x}" -f $_).PadLeft( 2, "0" )	}
			$char = $byte | Foreach-Object {
				if( [char]::IsLetterOrDigit($_) )
				{	[char] $_	}
				else
				{	"."	}
			}
			"$hex $char"
		}
	}
}

Function play( $path )
{
<#	.SYNOPSIS
		Play a media file with default player
#>
	if( Test-Path $path )
	{
		$startInfo = new-object System.Diagnostics.ProcessStartInfo
		$startInfo.fileName = $path
		$startInfo.windowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
		$process = New-Object System.Diagnostics.Process
		$process.startInfo = $startInfo
		$process.start( )
		$process.close( )
		#$process.kill( )
	}
	else
	{	Write-Host "$path is not a file"	}
}

Function speak()
{
<#	.SYNOPSIS
		Let the machine speak
	.DESCRIPTION
		Input can be a file, command line arguments or pipeline input
#>
	$voice = New-Object -ComObject SAPI.SPVoice
	$voice.Rate = -4
	if( $args )
	{
		if( Test-Path $args[0] )	# Speak out file content
		{
			ForEach( $line in Get-Content $args[0] )
			{	$voice.Speak( $line ) | out-null	}
		}
		else	# Speak out command line arguments
		{	$voice.Speak( $args ) | out-null	}
	}
	if( $input )	# Speak out values from pipeline
	{
		ForEach( $say in $input )
		{	$voice.Speak( $say ) | out-null	}
	}
}



## Network
Function getLocalIP()
{
<#	.SYNOPSIS
		Get local IP address
	.DESCRIPTION
		Use 'route' to determine local IP
#>
	route print 0* |
	%{
		if( $_ -match "\s{2,}0\.0\.0\.0" )
		{	$null,$null,$null,$LocalIP,$null = [regex]::replace($_.trimstart(" "),"\s{2,}",",").split(",")	}
	}
	return $LocalIP
}

Function getStandardGateway()
{
<#	.SYNOPSIS
		Get standard gateway
	.DESCRIPTION
		Use 'route' to determine standard gateway
#>
	route print 0* |
	%{
		if( $_ -match "\s{2,}0\.0\.0\.0" )
		{	$null,$null,$GatewayIP,$null,$null = [regex]::replace($_.trimstart(" "),"\s{2,}",",").split(",")	}
	}
	return $GatewayIP
}

Function netTraffic()
{
<#	.SYNOPSIS
		Measure network traffic of a command
	.EXAMPLE
		PS> netTraffic wget http://www.google.de/images/srpr/logo3w.png
#>
	if( $($args.count) -lt 1 )
	{
		Write-Host "usage: $($MyInvocation.MYCommand) <command> [<param1>...<paramN>]"
		exit -1
	}
	$class = "Win32_PerfRawData_Tcpip_NetworkInterface"
	$computer = "LocalHost" 
	$namespace = "root\CIMV2"
	$NICdatas = Get-WmiObject -class $class -computername $computer -namespace $namespace
	$names =	(0..($NICdatas.Length-1))
	$oldRcv =	(0..($NICdatas.Length-1)); $difRcv =	(0..($NICdatas.Length-1))
	$oldSent =	(0..($NICdatas.Length-1)); $difSsent =	(0..($NICdatas.Length-1))
	$oldTotal =	(0..($NICdatas.Length-1)); $difTotal =	(0..($NICdatas.Length-1))
	$index = 0
	ForEach( $NicData IN $NICdatas )
	{
		$names[$index] =	$NicData.Name
		$oldRcv[$index] =	$NicData.BytesReceivedPersec
		$oldSent[$index] =	$NicData.BytesSentPersec
		$oldTotal[$index] =	$NicData.BytesTotalPersec
		$index++
	}
	Invoke-Expression "$([String]$args)"
	$NICdatas = Get-WmiObject -class $class -computername $computer -namespace $namespace
	$index = 0
	ForEach( $NicData IN $NICdatas )
	{
		$difRcv[$index] =	$NicData.BytesReceivedPersec - $oldRcv[$index]
		$difSsent[$index] =	$NicData.BytesSentPersec - $oldSent[$index]
		$difTotal[$index] =	$NicData.BytesTotalPersec - $oldTotal[$index]
		$index++
	}
	For( $index = 0; $index -lt $NICdatas.Length; $index++ )
	{
		Write-Host "`n$($names[$index]):"
		Write-Host -noNewLine -ForeGroundColor DarkCyan "Revceived:`t"
		Write-Host -noNewLine -ForeGroundColor Cyan "$("{0:N0}" -f $([int]$difRcv[$index]))`t"
		Write-Host -noNewLine -ForeGroundColor DarkCyan "Sent:`t"
		Write-Host -noNewLine -ForeGroundColor Cyan "$("{0:N0}" -f $([int]$difSsent[$index]))`t"
		Write-Host -noNewLine -ForeGroundColor DarkCyan "Total:`t"
		Write-Host -ForeGroundColor Cyan "$("{0:N0}" -f $([int]$difTotal[$index]))"
	}
}

Function resolve( [String]$machine="localhost" )
{
<#	.SYNOPSIS
		Resolve hostname <=> ip address
	.PARAMETER machine
		Only one parameter for hostname or ip address
#>
	[System.Net.IPAddress]$IPobj = $null
	if( [System.Net.IPAddress]::tryparse($machine,[ref]$IPobj) -and $machine -eq $IPobj.tostring() )
	{
		Write-Host "Resolving IP-Address $machine to its associated DomainName"
		$serv,$null,$null,$name,$null = nslookup $machine 2>$null
		$name = $name -replace "Name:\s+",""
		Write-Host "=> $name"
	}
	else
	{
		Write-Host "Resolving DomainName $machine to its associated IP-Address"
		$null,$serv,$null,$null,$ipadr = nslookup $machine 2>$null
		$ipadr = $ipadr -replace "Address:\s+",""
		Write-Host "=> $ipadr"
	}
}



## Web
Function getWeather( [String]$city="Frankfurt", [String]$country="Germany", [Switch]$citysAvailable, `
					[String]$server="http://www.webservicex.net/globalweather.asmx?WSDL" )
<#	.SYNOPSIS
		Get weather from webservice
	.PARAMETER citysAvailable
		Show a list of available citys in country
#>
{
	$weatherProxy = New-WebServiceProxy $server
	If( $citysAvailable )
	{
		($weatherProxy.GetCitiesByCountry( $country )).Split("`r`n") | `
			?{$_ -match "City"} | Sort-Object | `
			%{$_ -replace "<City>",""} | %{$_ -replace "</City>",""}
	}
	Else
	{	([XML]$weatherProxy.GetWeather( $city, $country )).CurrentWeather	}
}

Function sendFax( [String]$number, [String]$message, [String]$mail="noreply@mail.com", [String]$subject="sendFax()", `
					[String]$receiver="recipient", [String]$server="http://www.webservicex.net/fax.asmx?WSDL" )
<#	.SYNOPSIS
		Send a free SMS (worldwide)
	.PARAMETER number
		Fax number of receiver without leading zero
	.PARAMETER message
		The message text to send
	.PARAMETER mail
		Mail address of sender (noreply@mail.com)
#>
{
	$faxProxy = New-WebServiceProxy $server
	$faxProxy.SendTextToFax( $mail, $subject, $number, $message, $receiver)
}

Function sendSMS( [String]$mobile, [String]$message, [String]$mail="noreply@mail.com", [String]$country="49", `
					[String]$server="http://www.webservicex.net/sendsmsworld.asmx?WSDL" )
<#	.SYNOPSIS
		Send a free SMS (worldwide)
	.PARAMETER mobile
		Mobile number of receiver without leading zero
	.PARAMETER message
		The message text to send
	.PARAMETER mail
		Mail address of sender (noreply@mail.com)
	.PARAMETER country
		Country code without leading zero or plus (49)
#>
{
	$smsProxy = New-WebServiceProxy $server
	$smsProxy.sendSMS( $mail, $country, $mobile, $message )
}

Function translate( [String]$word, [String]$mode="EnglishTOGerman", `
					[String]$server="http://www.webservicex.net/TranslateService.asmx?WSDL" )
<#	.SYNOPSIS
		Send a free SMS (worldwide)
	.PARAMETER mode
		Translation mode (EnglishTOGerman)
	.PARAMETER word
		Word which will be translated
#>
{
	$translateProxy = New-WebServiceProxy $server
	$translateProxy.Translate( "$mode", "$word" )
}



Write-Host -NoNewLine -ForeGroundColor 13	" _ __                               "
Write-Host -NoNewLine -ForeGroundColor 9	"      _            _  _  "
Write-Host -ForeGroundColor 11				"          ____"
Write-Host -NoNewLine -ForeGroundColor 13	"| '_ \   ___  __      __  ___  _ __ "
Write-Host -NoNewLine -ForeGroundColor 9	" ___ | |__    ___ | || | "
Write-Host -ForeGroundColor 11				"  __   __|___ \"
Write-Host -NoNewLine -ForeGroundColor 13	"| |_) | / _ \ \ \ /\ / / / _ \| '__|"
Write-Host -NoNewLine -ForeGroundColor 9	"/ __|| '_ \  / _ \| || | "
Write-Host -ForeGroundColor 11				"  \ \ / /  __) |"
Write-Host -NoNewLine -ForeGroundColor 13	"| .__/ | (_) | \ V  V / |  __/| |   "
Write-Host -NoNewLine -ForeGroundColor 9	"\__ \| | | ||  __/| || | "
Write-Host -ForeGroundColor 11				"   \ V /  / __/"
Write-Host -NoNewLine -ForeGroundColor 13	"|_|     \___/   \_/\_/   \___||_|   "
Write-Host -NoNewLine -ForeGroundColor 9	"|___/|_| |_| \___||_||_| "
Write-Host -ForeGroundColor 11				"    \_/  |_____|"
Get-Date
