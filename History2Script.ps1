# Write shell command history to a scriptfile
#

param( [String]$filename="history.ps1",[Int]$last=$MaximumHistoryCount )

if( $filename -contains "help" )
{
	Write-Host "usage: $($MyInvocation.MYCommand) <[-filename] filename> {<[-last] numberOfLastEntries>}"
	exit
}

$history = $(Get-History -count $last)
$linecount = 0
ForEach( $line IN $history )
{
	Add-Content $filename $line.CommandLine
	$linecount++
}

Write-Host "Historys last $linecount commands written into $filename"