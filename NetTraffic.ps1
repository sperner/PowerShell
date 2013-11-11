# Simple wrapper to measure network traffic of a given command
# (diff sent/recv bytes before and after invokation)
#

# no args given -> print usage
if( $($args.count) -lt 1 )
{
	Write-Host "usage: $($MyInvocation.MYCommand) <command> [<param1>...<paramN>]"
	exit -1
}

# combine args to command
for( $index=0; $index -lt $($args.count); $index++ )
{
	$command += $args[$index]
	$command += " "
}

# get old network statistics
$computer = "LocalHost" 
$namespace = "root\CIMV2"
$NICdatas = Get-WmiObject -class Win32_PerfRawData_Tcpip_NetworkInterface -computername $computer -namespace $namespace

$names =		(0..($NICdatas.Length-1))
$oldReceived =	(0..($NICdatas.Length-1))
$oldSent =		(0..($NICdatas.Length-1))
$oldTotal =		(0..($NICdatas.Length-1))
$newReceived =	(0..($NICdatas.Length-1))
$newSsent =		(0..($NICdatas.Length-1))
$newTotal =		(0..($NICdatas.Length-1))
$diffReceived =	(0..($NICdatas.Length-1))
$diffSsent =	(0..($NICdatas.Length-1))
$diffTotal =	(0..($NICdatas.Length-1))

# save old network statistics
$aktNum = 0
ForEach( $NicData IN $NICdatas )
{
	$names[$aktNum] =		$NicData | Select Name
	$oldReceived[$aktNum] =	$NicData | Select BytesReceivedPersec
	$oldSent[$aktNum] =		$NicData | Select BytesSentPersec
	$oldTotal[$aktNum] =	$NicData | Select BytesTotalPersec
	$aktNum++
}

# invoke command
Invoke-Expression $command

# get new network statistics
$NICdatas = Get-WmiObject -class Win32_PerfRawData_Tcpip_NetworkInterface -computername $computer -namespace $namespace

# save new network statistics
$aktNum = 0
ForEach( $NicData IN $NICdatas )
{
	$newReceived[$aktNum] =	$NicData | Select BytesReceivedPersec
	$newSsent[$aktNum] =	$NicData | Select BytesSentPersec
	$newTotal[$aktNum] =	$NicData | Select BytesTotalPersec
	$aktNum++
}

# calculate the differences beteen old and new
For( $index = 0; $index -lt $NICdatas.Length; $index++ )
{
	$diffReceived[$index] =	[int]$newReceived[$index].BytesReceivedPersec - [int]$oldReceived[$index].BytesReceivedPersec
	$diffSsent[$index] =	[int]$newSsent[$index].BytesSentPersec - [int]$oldSent[$index].BytesSentPersec
	$diffTotal[$index] =	[int]$newTotal[$index].BytesTotalPersec - [int]$oldTotal[$index].BytesTotalPersec
}

# print the differences
For( $index = 0; $index -lt $NICdatas.Length; $index++ )
{
	Write-Host "`n$($names[$index].Name)`n`rRevceived:`t$("{0:N0}" -f $($diffReceived[$index]))`tSent:`t$("{0:N0}" -f $($diffSsent[$index]))`tTotal:`t$("{0:N0}" -f $($diffTotal[$index]))"
}
