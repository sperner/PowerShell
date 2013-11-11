# VMware/vSphere Store Server, User an Password in a xml-file
#
# usage:
# StoreVMwareCredentials.ps1 <server> <user> <pass> <file>
#
# example:
# StoreVMwareCredentials.ps1 smc-vm-019.smc.fsc.net root pass1234 credentials.xml
#
#
# Read connection credentials:
# $creds = Get-VICredentialStoreItem -file credentials.xml
#
# Open connection to server:
# Connect-VIServer -Server $creds.Host -user $creds.User -password $creds.Password
#

if( $args[0] -AND $args[1] -AND $args[2] -AND $args[3] )
{
	$serv = $args[0]
	$user = $args[1]
	$pass = $args[2]
	$file = $args[3]
}
else
{
	$serv = read-host "Enter hostname"
	$user = read-host "Enter username"
	$pass = read-host "Enter password"
	$file = read-host "Enter filename"
}
New-VICredentialStoreItem -Host $serv -User $user -Password $pass -file $file
