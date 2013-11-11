# Start a given script multithreaded for a bunch of remote machines
#


Param(	$ScriptFile = $(Read-Host "Enter the script file"), 
		$ComputerList = $(Read-Host "Enter the Location of the computerlist"),
		$MaxThreads = 20,
		$SleepTimer = 500,
		$MaxWaitAtEnd = 600,
		$OutputType = "Text"	)


Write-Host "Killing existing jobs ... " -noNewLine
Get-Job | Remove-Job -Force
Write-Host "Done."


$numJobs = 0
$Computers = Get-Content $ComputerList
ForEach( $Computer in $Computers )
{
	While( $(Get-Job -state running).count -ge $MaxThreads )
	{
		Write-Progress	-Activity "Creating Server List" 
						-Status "Waiting for threads to close" 
						-CurrentOperation "$numJobs threads created - $($(Get-Job -state running).count) threads open" 
						-PercentComplete ($numJobs / $Computers.count * 100)
		Start-Sleep -Milliseconds $SleepTimer
	}

	$numJobs++
	Start-Job -FilePath $ScriptFile -ArgumentList $Computer -Name $Computer | Out-Null
	Write-Progress	-Activity "Creating Server List" 
					-Status "Starting Threads" 
					-CurrentOperation "$numJobs threads created - $($(Get-Job -state running).count) threads open" 
					-PercentComplete ($numJobs / $Computers.count * 100)
    
}
$allStartedAt = Get-date


While( $(Get-Job -State Running).count -gt 0 )
{
	$ComputersStillRunning = ""
	ForEach( $System  in $(Get-Job -state running) )
	{
		$ComputersStillRunning += ", $($System.name)"
	}
	$ComputersStillRunning = $ComputersStillRunning.Substring( 2 )

	Write-Progress	-Activity "Creating Server List" 
					-Status "$($(Get-Job -State Running).count) threads remaining" 
					-CurrentOperation "$ComputersStillRunning" 
					-PercentComplete ($(Get-Job -State Completed).count / $(Get-Job).count * 100)
	If( $(New-TimeSpan $allStartedAt $(Get-Date)).totalseconds -ge $MaxWaitAtEnd )
	{
		Write-Host "Killing all jobs still running . . ."
		Get-Job -State Running | Remove-Job -Force
	}
	Start-Sleep -Milliseconds $SleepTimer
}


Write-Host "Reading all jobs"
If( $OutputType -eq "Text" )
{
    ForEach( $Job in Get-Job )
	{
        Write-Host "$($Job.Name)"
        Write-Host "****************************************"
        Receive-Job $Job
        Write-Host " "
    }
}
ElseIf( $OutputType -eq "GridView" )
{
    Get-Job | Receive-Job | Select-Object * -ExcludeProperty RunspaceId | out-gridview
} 
