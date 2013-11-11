# Threading in powershell
# ...far more stupid than in stupid java
# wtf???

Function f1()
{
	Write-Host "1: $MyInvocation.ScriptName"
	sleep 1
}

Function f2()
{
	Write-Host "2: $MyInvocation.ScriptName"
	sleep 2
}

Function f3()
{
	Write-Host "3: $MyInvocation.ScriptName"
	sleep 3
}

<#
Get-Job                           Gets Windows PowerShell background jobs that are running in the current ...
Receive-Job                       Gets the results of the Windows PowerShell background jobs in the curren...
Remove-Job                        Deletes a Windows PowerShell background job.
Start-Job                         Starts a Windows PowerShell background job.
Stop-Job                          Stops a Windows PowerShell background job.
Wait-Job                          Suppresses the command prompt until one or all of the Windows PowerShell...
#>

#$job1 = Start-Job { f1 }	# no ("external" defined) functions?
#$job2 = Start-Job { f2 }
#$job3 = Start-Job { f3 }
$job1 = Start-Job { Write-Host "1: $MyInvocation.ScriptName" }	# no output from a job?
$job2 = Start-Job { Write-Host "2: $MyInvocation.ScriptName" }
$job3 = Start-Job { Write-Host "3: $MyInvocation.ScriptName" }

Wait-Job $job1.Id
Wait-Job $job2.Id
Wait-Job $job3.Id

#Receive-Job $job1.Id
#Receive-Job $job2.Id
#Receive-Job $job3.Id

#Stop-Job $job1.Id
#Stop-Job $job2.Id
#Stop-Job $job3.Id

Remove-Job $job1.Id
Remove-Job $job2.Id
Remove-Job $job3.Id
