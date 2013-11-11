# eMail: Store Username an Password in a xml-file
#
# usage:
#   StoreEMailCredentials.ps1 <{read|write}> <filename>
#
# parameter:
#   read         Read from file and return pscredential
#   write        Write via dialog given credentials to file
#

# Write
#$credential = Get-Credential
#$credential.Password | ConvertFrom-SecureString | Set-Content $file
# Read
#$username = 'domain\user'
#$password = Get-Content $file | ConvertTo-SecureString
#$credential = New-Object System.Management.Automation.PsCredential $user,$pass

param( $command="write", $file="credentials.xml" )

If( $command -eq "write" )
{
	$row = "" | Select Username,Password
	$credential = Get-Credential
	$row.Username = $credential.UserName
	$row.Password = $credential.Password | ConvertFrom-SecureString
	$row | Export-CliXML $file
}
ElseIf( $command -eq "read" )
{
	$row = Import-CliXML $file
	$credential = New-Object System.Management.Automation.PsCredential $row.username,($row.password | ConvertTo-SecureString)
	return $credential
}
Else
{
	Write-Error "Unknown command $command"
	Write-Host "usage: $($MyInvocation.MYCommand) <read|write> <credfile>"
	exit -1
}
