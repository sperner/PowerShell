# Handling processes in powershell
#

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
Debug-Process                     Debugs one or more processes running on the local computer.
Get-Process                       Gets the processes that are running on the local computer or a remote computer
Start-Process                     Starts one or more processes on the local computer.
Stop-Process                      Stops one or more running processes.
Wait-Process                      Waits for the processes to be stopped before accepting more input.
#>

$process1 = Start-Process find.exe	# no ("external" defined) functions?
$process2 = Start-Process sort.exe	# no return of an object!
$process3 = Start-Process mem.exe	# so no returned id or whatever else!
#$process1 = Start-Process { Write-Host "1: $MyInvocation.ScriptName" }	# no output from a Process?
#$process2 = Start-Process { Write-Host "2: $MyInvocation.ScriptName" }
#$process3 = Start-Process { Write-Host "3: $MyInvocation.ScriptName" }

Wait-Process $process1.Id
Wait-Process $process2.Id
Wait-Process $process3.Id

Stop-Process $process1.Id
Stop-Process $process2.Id
Stop-Process $process3.Id
