# Pipeline testing
#

#param( [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)][String[]]$aParam )

Write-Host "$($MyInvocation.Line)"

foreach ($i in $input) {
	if( !$args )
    {	$i	}
}
