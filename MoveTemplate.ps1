# Move a vmware virtual machine template to another host and/or datastore
# work in progress...
# working, but convert and move lines are commented out for testing
#

param(	[string]$template, `
		[string]$destHost, `
		[string]$srcHost, `
		[string]$datastore, `
		[Switch]$allLinux, `
		[Switch]$allWindows, `
		[Switch]$help)

if( ((!$template -or (!$destHost -and !$datastore)) -and !($allLinux -or $allWindows)) -or $help )
{
	Write-Host "usage: $($MyInvocation.MYCommand) <template> {<destHost/esx(i)> <datastore>} [<srcHost/esx(i)>]"
	Write-Host "       DESTHOST and/or DATASTORE is mandatory"
	exit -1
}



# Get a group of templates by GuestFamily - not always set!
function getLinuxTemplates
{
    $linuxTemplates = Get-Template | Get-View | Where {$_.Guest.GuestFamily -eq 'linuxGuest'} | Get-VIObjectByVIView
    return $linuxTemplates
}

function getWindowsTemplates
{
    $windowsTemplates = Get-Template | Get-View | Where {$_.Guest.GuestFamily -eq 'windowsGuest'} | Get-VIObjectByVIView
    return $windowsTemplates
}

# Get by GuestId
#freebsdGuest
#otherLinux64Guest
#rhel5Guest
#rhel5_64Guest
#rhel6_64Guest
#slesGuest
#sles10Guest
#sles10_64Guest
#sles11_64Guest
#solaris10Guest
#ubuntuGuest
#ubuntu64Guest
#winLonghornGuest (2008)
#winLonghorn64Guest (2008 64)
#winNetStandardGuest (2003-std)
#winNetEnterpriseGuest (2003-ent)
#winNetEnterprise64Guest (2003-ent 64)
#windows7Server64Guest (2008r2 64)
#winXPProGuest
#...



function mvTemplate( [parameter(Mandatory=$true)][string]$template, [string]$destHost, [string]$datastore )
{
	if( !$destHost -and !$datastore )
	{
		Write-Host "Error: no destHost or datastore given - aborting"
		return -1
	}

	Write-Host "Converting $template to VM ..." -noNewLine
	#$vm = Set-Template -Template (Get-Template $template) -ToVM 
	Write-Host " OK"

	if( $destHost -and $datastore )
	{
		Write-Host "Migrate template: > $template < to destHost: > $destHost < and storage: > $datastore < ..." -noNewLine
		#Move-VM -VM (Get-VM $vm) -Destination (Get-destHost $destHost) -Datastore (Get-Datastore $datastore) -Confirm:$false
		#(Get-VM $vm | Get-View).MarkAsTemplate() | Out-Null
		Write-Host " OK"
	}        
	elseif( $destHost -and !$datastore )
	{
		Write-Host "Migrate template: > $template < to destHost: > $destHost < ..." -noNewLine
		#Move-VM -VM $vm -Destination (Get-destHost $destHost) -Confirm:$false
		#(Get-VM $vm | Get-View).MarkAsTemplate() | Out-Null
		Write-Host " OK"
	}
	elseif( !$destHost -and $datastore )
	{
		Write-Host "Migrate template: > $template < to storage: > $datastore < ..." -noNewLine
		#Move-VM -VM $vm -Datastore (Get-Datastore $datastore) -Confirm:$false
		#(Get-VM $vm | Get-View).MarkAsTemplate() | Out-Null
		Write-Host " OK"
	}
}

# Move to another host (/and datastore)
if( $template )
{
	if( $srcHost )
	{
		$templates2BeMoved = Get-Template $template -Location $srcHost
	}
	else
	{
		$templates2BeMoved = Get-Template $template
	}
	foreach( $template4Moving in $templates2BeMoved )
	{
		Move-Template -template $template4Moving -destHost $destHost -datastore $datastore
	}
	exit
}

# Move all linux templates
if( $allLinux )
{
	$templates2BeMoved = getLinuxTemplates
	foreach( $template4Moving in $templates2BeMoved )
	{
		Move-Template -template $template4Moving -destHost $destHost -datastore $datastore
	}
}

# Move all windows templates
if( $allWindows )
{
	$templates2BeMoved = getWindowsTemplates
	foreach( $template4Moving in $templates2BeMoved )
	{
		Move-Template -template $template4Moving -destHost $destHost -datastore $datastore
	}
}

