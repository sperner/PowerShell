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
#Set-Alias !$ $$ #not working!
#Set-Alias cat Get-Content
##Set-Alias cd Set-Location
#Set-Alias clear Clear-Host
#Set-Alias cp Copy-Item
#Set-Alias date Get-Date
##Set-Alias df Get-PSDrive
#Set-Alias diff Compare-Object
#$(_Set-Function) du
#$(_Set-Function) env
#$(_Set-Function) file
#$(_Set-Function) find
#$(_Set-Function) free
#$(_Set-Function) grep
##Set-Alias head Select-Object -first 20
##Set-Alias kill Stop-Process
#Set-Alias ls Get-ChildItem
#$(_Set-Function) lt
#$(_Set-Function) lz
#Set-Alias man Get-Help
#$(_Set-Function) md5 chksum(md5)
#Set-Alias mkdir New-Item -type "directory"
##Set-Alias more more
#Set-Alias mv Move-Item
#Set-Alias popd Pop-Location
#Set-Alias pushd Push-Location
##Set-Alias ps Get-Process
#Set-Alias pwd Get-Location
##Set-Alias rc Get-Service
#$(_Set-Function) repeat
#Set-Alias rm Remove-Item
#Set-Alias rmdir Remove-Item
#$(_Set-Function) sed
#$(_Set-Function) sha1 chksum(sha1)
#$(_Set-Function) sha256 chksum(sha256)
#$(_Set-Function) sha512 chksum(sha512)
#Set-Alias sort Sort-Object
##Set-Alias tail Select-Object -last 20
#Set-Alias tee Tee-Object
##Set-Alias time Measure-Command
#$(_Set-Function) top
##Set-Alias touch New-Item -type "file"
#$(_Set-Function) uname
#$(_Set-Function) uptime
##Set-Alias wc Measure-Object -character -word -line
#$(_Set-Function) wget
##Set-Alias which Get-Command
#$(_Set-Function) who
#$(_Set-Function) whois



If( Get-Alias cd 2>$null )
{	Remove-Item -path alias:cd	}
Function cd( [String]$path )
{
<#	.SYNOPSIS
		Change directory with '-' feature
	.DESCRIPTION
		Better, near unix-like, cd implementation
	.EXAMPLE
		Switch to previous directory
		PS C:\> cd -
#>
	If( !$path )
	{	$dir = $HOME	}
	Else
	{
		If( $path -eq '-' )
		{	$dir = $LastDir	}
		Else
		{
			If( !(Test-Path $path) )
			{	Write-Host "$path is not a valid path"	}
			Else
			{	$dir = $path	}
		}
	}
	Set-Variable -Name LastDir -Value $(Get-Location) -Scope global
	If( $dir )
	{	Set-Location $dir	}
}

Function chksum( $file, $algo="MD5" )
{ 
<#	.SYNOPSIS
		Checksum calculator
	.DESCRIPTION
		Possible algorithms md5, sha1, sha256, sha512
#>
	$algo = [System.Security.Cryptography.HashAlgorithm]::Create( $algo )
	$stream = New-Object System.IO.FileStream( $file, [System.IO.FileMode]::Open )
	$stringBuilder = New-Object System.Text.StringBuilder
	$algo.ComputeHash($stream) | % { [void] $stringBuilder.Append($_.ToString("x2")) }
	$stringBuilder.ToString()
	$stream.Dispose()
}

Function df( )
{
<#	.SYNOPSIS
		Measure file or folder size
	.DESCRIPTION
		Better, near unix-like, du implementation
#>
	Get-WmiObject -Query "Select * From Win32_LogicalDisk" |
	Format-Table -AutoSize @{Label="Vol";Expression={$_.DeviceID};Align="Left"}, `
		@{Label="Name";Expression={$_.VolumeName};Align="Left"}, `
		@{Label="Size";Expression={FHR $_.Size};Align="Right"}, `
		@{Label="Used";Expression={FHR (($_.Size)-($_.FreeSpace))};Align="Right"}, `
		@{Label="Available";Expression={FHR $_.FreeSpace};Align="Right"}, `
		@{Label="Use%";Expression={"{0:#}%" -f ((($_.Size)-($_.FreeSpace))/($_.Size)*100)};Align="Right"}, `
		@{Label="Type";Expression={$_.FileSystem};Align="Center"}, `
		@{Label="Description";Expression={$_.Description};Align="Left"}, `
		@{Label="Provider";Expression={$_.ProviderName};Align="Left"}
}

Function du( [String]$path = '.', [Switch]$s )
{
<#	.SYNOPSIS
		Measure file or folder size
	.DESCRIPTION
		Better, near unix-like, du implementation
	.PARAMETER s
		Only summarize
#>
	$sumCount = $sumSize = 0
	$list =@()
	ForEach( $object in $(Get-Childitem $path -Force) )
	{
		$row = "" | Select-Object Mode, Path, Count, Size
		If( $object.Attributes -eq "Directory" )
		{
			$row.Mode =	$object.Mode
			$row.Path =	$object.Fullname
			ForEach( $child in $(Get-Childitem $object.FullName -Recurse -Force) )
			{
				$row.Count +=	1
				$row.Size +=	$child.Length
			}
		}
		Else
		{
			$row.Mode =		$object.Mode
			$row.Path =		$object.Fullname
			$row.Count =	1
			$row.Size =		$object.Length
		}
		$sumCount +=	$row.Count
		$sumSize +=		$row.Size
		If( !$s )
		{	$list += $row	}
	}
	$row = "" | Select-Object Mode, Path, Count, Size
	$row.Mode =		"Summ:"
	$row.Path =		$path
	$row.Count =	$sumCount
	$row.Size =		[System.Convert]::ToString("{0:N0}" -f $sumSize)
	$list += $row
	$list | Format-Table -auto
}

Function env( )
{
<#	.SYNOPSIS
		Get environment variables
	.DESCRIPTION
		Better, near unix-like, env implementation
#>
	Get-ChildItem env:
}

Function FHR($size)
{
<#	.SYNOPSIS
		Format human readable
	.DESCRIPTION
		Decimal number to size
#>
	Switch ($size)
	{
		{$_ -ge 1PB}{"{0:n3} PB" -f ($size / 1PB); break}
		{$_ -ge 1TB}{"{0:n3} TB" -f ($size / 1TB); break}
		{$_ -ge 1GB}{"{0:n3} GB" -f ($size / 1GB); break}
		{$_ -ge 1MB}{"{0:n3} MB" -f ($size / 1MB); break}
		{$_ -ge 1KB}{"{0:n3} KB" -f ($size / 1KB); break}
		default {"{0}" -f ($size) + "B"}
	}
}

Function file( [String]$path )
{
<#	.SYNOPSIS
		Get file information
	.DESCRIPTION
		Better, near unix-like, file implementation
#>
	if( !$path )
	{	Write-Host "usage: $($MyInvocation.MYCommand) <path/filename>"	}
	else
	{
		if( Test-Path $path )
		{
			New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR > $null
			$file = Get-ChildItem $path
			(Get-ItemProperty hkcr:$($file.Extension)).'(default)'
			Remove-PSDrive HKCR
		}
		else
		{	Write-Host "Not a file: $($args[0])"	}
	}
}

Function find( [String]$path=".", [String]$expression )
{
<#	.SYNOPSIS
		Find files by name
	.DESCRIPTION
		Better, near unix-like, find implementation
	.PARAMETER path
		Path to begin the search
	.PARAMETER expression
		Expression to search in filename for
	.EXAMPLE
		PS C:\> find C:\windows *.ini
#>
	If( !(Test-Path $path) )
	{
		Write-Host "usage: $($MyInvocation.MYCommand) <directory> <expression>"
		return
	}
	If( $expression.Contains("*") )
	{	Get-ChildItem -Recurse "$path" | Where {$_.Name -like "$expression"}	}
	Else
	{	Get-ChildItem -Recurse "$path" | Where {$_.Name -match "$expression"}	}
}

Function free( )
{
<#	.SYNOPSIS
		Show memory summary
	.DESCRIPTION
		Better, near unix-like, free implementation
#>
	$mem = Get-WmiObject -Class Win32_OperatingSystem
	$swap = Get-WmiObject -Class Win32_PageFileUsage
	$memTotal = $mem.TotalVisibleMemorySize * 1024
	$memUsed = ($mem.TotalVisibleMemorySize-$mem.FreePhysicalMemory) * 1024
	$memFree = $mem.FreePhysicalMemory * 1024
	$swapTotal = $swap.AllocatedBaseSize * 1024 * 1024
	$swapUsed = $swap.CurrentUsage * 1024 * 1024
	$swapFree = ($swap.AllocatedBaseSize-$swap.CurrentUsage) * 1024 * 1024
	If( $mem.PAEEnabled )
	{	Write-Host -ForegroundColor Gray "PAE is enabled`n"	}
	Write-Host "`t total`t`t used`t`t free`t`t description"
	Write-Host "mem`t$(FHR($memTotal))`t$(FHR($memUsed))`t$(FHR($memFree))`t$($mem.Description)"
	Write-Host "swap`t$(FHR($swapTotal))`t$(FHR($swapUsed))`t$(FHR($swapFree))`t$($swap.Description)"
	Write-Host "total`t$(FHR($memTotal+$swapTotal))`t$(FHR($memUsed+$swapUsed))`t$(FHR($memFree+$swapFree))"
}

Function grep( )
{
<#	.SYNOPSIS
		Grep into files(treams)
	.DESCRIPTION
		Better, near unix-like, grep implementation
	.EXAMPLE
		Search in a textfile
		PS C:\> grep help.txt author
	.EXAMPLE
		Search the output of a command
		PS C:\> grep ls ini
	.EXAMPLE
		Search in a pipe
		PS C:\> ls | grep ini
#>
	If( !$($args[0]) -or ($($args[0]) -eq "-help") )
	{
		Write-Host "usage: $($MyInvocation.MYCommand) <file/command> [<param1>...<paramN>] <searchstring>"
		Write-Host "or:    <command> | $($MyInvocation.MYCommand) <searchstring>"
		return
	}
	$search = [String]$args[$($args.count-1)]
	If( Test-Path $args[0] )	#write-host "I got a file"
	{
		$filename = $args[0]
		If( $search.Contains("*") )
		{	$(Get-Content $filename) | Out-String -Stream | Where {$_ -like $search}	}
		Else
		{	$(Get-Content $filename) | Out-String -Stream | Where {$_ -match $search}	}
	}
	Else
	{
		If( $args.count -gt 1 )	#write-host "I got a command"
		{
			For( $index=0; $index -lt $($args.count-1); $index++ )
			{
				$command += $args[$index]
				$command += " "
			}
			If( $search.Contains("*") )
			{	$(Invoke-Expression $command) | Out-String -Stream | Where {$_ -like $search}	}
			Else
			{	$(Invoke-Expression $command) | Out-String -Stream | Where {$_ -match $search}	}
		}
		Else	#write-host "I´m in a pipe"
		{
			ForEach( $line in ($input | Out-String -Stream) )
			{
				$line.tostring | Where {$_ -match $search}
				If( $search.Contains("*") )
				{	$line | Where {$_ -like $search}	}
				Else
				{	$line | Where {$_ -match $search}	}
			}
		}
	}
}

Function head( )
{
<#	.SYNOPSIS
		Print only the head of a file(stream)
	.DESCRIPTION
		Better, near unix-like, head implementation
	.EXAMPLE
		Print first lines of a textfile
		PS C:\> head help.txt 10
	.EXAMPLE
		Print first lines from a pipe
		PS C:\> ls | head 10
#>
	If( $($args[0]) -eq "-help" )
	{
		Write-Host "usage: $($MyInvocation.MYCommand) [<file>] <numLines>"
		return
	}
	$lines = 20
	If( $args[0] )
	{
		If( !$(Test-Path $args[$($args.count-1)]) )
		{	$lines = $args[$($args.count-1)]	}
		If( Test-Path $args[0] )	#write-host "I got a file"
		{
			$filename = $args[0]
			Get-Content $filename | Out-String -Stream | Select-Object -First $lines
			return
		}
	}
	$aktLine = 0
	ForEach( $line in ($input | Out-String -Stream) )	#write-host "I´m in a pipe"
	{
		$line
		$aktLine++
		If( $aktLine -eq $lines )
		{	break	}
	}
}

If( Get-Alias kill 2>$null )
{	Remove-Item -path alias:kill	}
Function kill( )
{
<#	.SYNOPSIS
		Terminate a process by id or name
	.DESCRIPTION
		Better, near unix-like, kill(it) implementation
#>
	If( !$args[0] )
	{
		Write-Host "usage: $($MyInvocation.MYCommand) <process-id/-name>"
		return
	}
	If( $($args[0]).GetType().Name -eq "String" )
	{
		ForEach( $process in (Get-Process $args[0] 2>$null) )
		{
			Write-Host "Terminating $($process.Name) with ID $($process.Id)"
			Stop-Process $process.Id
		}
	}
	Else
	{
		ForEach( $id in $args )
		{
			Write-Host "Terminating $((Get-Process -Id $($args[0])).Name) with ID $id"
			Stop-Process $id
		}
	}
}

Function lt( [String]$path="." )
{
<#	.SYNOPSIS
		List files/folders sorted by time
#>
	Get-ChildItem $path | Sort-Object LastWriteTime
}

Function lz( [String]$path="." )
{
<#	.SYNOPSIS
		List files/folders sorted by size
#>
	Get-ChildItem $path | Sort-Object Length
}

Function md5( $file )
{
<#	.SYNOPSIS
		MD5 cheksum calculator
#>
	chksum -file $file -algo "MD5"
}

Function profile( )
{
<#	.SYNOPSIS
		Edit default shell profile
#>
	If( !(Test-Path $PROFILE) )
	{
		Write-Host "$PROFILE doesn´t exist"
		If( (Read-Host "Want to create it? (y/n)") -eq "y" )
		{
			$split = $PROFILE.split("\")
			For( $i=0; $i -lt ($split.count - 1); $i++ )
			{	$directory += $split[$i] + "\"	}
			If( !(Test-Path $directory) )
			{	New-Item -type "directory" $directory	}
			New-Item -type "file" $PROFILE
		}
	}
	$oldProfile = $PROFILE + ".old"
	Copy-Item $PROFILE $oldProfile
	notepad $PROFILE
}

If( Get-Alias ps 2>$null )
{	Remove-Item -path alias:ps	}
Function ps( [String]$process )
{
<#	.SYNOPSIS
		Print processes
	.DESCRIPTION
		Better, near unix-like, ps implementation
	.PARAMETER process
		The name of a process to search for
#>
	Get-WmiObject win32_process | Select-Object `
				@{n="PID";		e={$_.ProcessId}}, `
				@{n="PPID";		e={$_.ParentProcessId}}, `
				@{n="Threads";	e={$_.ThreadCount}}, `
				@{n="User";		e={$_.GetOwner().User}}, `
				@{n="Memory";	e={"$($_.WorkingSetSize/1MB) MB"}}, `
				@{n="KTime";	e={new-object System.TimeSpan $_.KernelModeTime}}, `
				@{n="UTime";	e={new-object System.TimeSpan $_.UserModeTime}}, `
				@{n="Name";		e={$_.ProcessName}}, `
				@{n="Command";	e={$_.CommandLine}} `
				| Where {$_.Name -match $process} | Format-Table -auto
}

Function rc( [String]$service, [switch]$running, [switch]$stopped, [switch]$auto, [switch]$manual, [switch]$disabled, [switch]$help )
{
<#	.SYNOPSIS
		Print services
	.DESCRIPTION
		Better, near unix-like, rc implementation
	.PARAMETER service
		The name of a service to search for
	.EXAMPLE
		Show only running and manual started services
		PS C:\> rc -running -manual
#>
	If( $help )
	{
		Write-Host "usage: $($MyInvocation.MYCommand) [-{running,stopped}] [-{auto,manual,disabled}] [-help]"
		return
	}
	If( $running -and $stopped )
	{
		Write-Host "In this version of $($MyInvocation.MYCommand) you can only choose one state at a time"
		return
	}
	If( ($auto -and $manual) -or ($auto -and $disabled) -or ($manual -and $disabled) )
	{
		Write-Host "In this version of $($MyInvocation.MYCommand) you can only choose one startmode at a time"
		return
	}
	If( $running )
	{	$state = "Running"	}
	If( $stopped )
	{	$state = "Stopped"	}
	If( $auto )
	{	$startMode = "Auto"	}
	If( $manual )
	{	$startMode = "Manual"	}
	If( $disabled )
	{	$startMode = "Disabled"	}
	If( $state -and $startMode )
	{	Get-WmiObject Win32_Service | Where {$_.Name -match $service} | Where-Object { $_.State -eq "$state" -and $_.StartMode -eq "$startMode"} | Format-Table	}
	ElseIf( $state )
	{	Get-WmiObject Win32_Service | Where {$_.Name -match $service} | Where-Object { $_.State -eq "$state" } | Format-Table	}
	ElseIf( $startMode )
	{	Get-WmiObject Win32_Service | Where {$_.Name -match $service} | Where-Object { $_.StartMode -eq "$startMode" } | Format-Table	}
	Else
	{	Get-WmiObject Win32_Service | Where {$_.Name -match $service} | Format-Table	}
}

Function repeat( $command, $times=3, $sleep=0 )
{
<#	.SYNOPSIS
		Repeat a command several times
	.DESCRIPTION
		Better, near unix-like, repeat implementation
#>
	If( !$command )
	{
		Write-Host "usage: $($MyInvocation.MYCommand) <command> [<times>] [<sleep>]"
		exit -1
	}
	For( $i = 0; $i -lt $times; $i++ )
	{
		Invoke-Expression $command
		Sleep -Seconds $sleep
	}
}

Function sed( )
{
<#	.SYNOPSIS
		Sed into files(treams)
	.DESCRIPTION
		Better, near unix-like, sed implementation
	.EXAMPLE
		Substitude in a textfile
		PS C:\> sed help.txt author creator
	.EXAMPLE
		Substitude the output of a command
		PS C:\> sed ls inf txt
	.EXAMPLE
		Substitude in a pipe
		PS C:\> ls | sed inf txt
#>
	If( !$($args[0]) -or ($($args[0]) -eq "-help") )
	{
		Write-Host "usage: $($MyInvocation.MYCommand) <file/command> [<param1>...<paramN>] <search> <replace>"
		Write-Host "or:    <command> | $($MyInvocation.MYCommand) <searchstring> <replacestring>"
		exit
	}
	$expression = $args[$($args.count-2)]
	$replacement = $args[$($args.count-1)]
	If( Test-Path $args[0] )	#write-host "I got a file"
	{
		$filename = $args[0]
		$(Get-Content $filename) | Out-String -Stream | ForEach-Object{$_ -replace "$expression", "$replacement"}
	}
	Else
	{
		If( $args.count -gt 2 )	#write-host "I got a command"
		{
			For( $index=0; $index -lt $($args.count-2); $index++ )
			{
				$command += $args[$index]
				$command += " "
			}
			$(Invoke-Expression $command) | Out-String -Stream | ForEach-Object{$_ -replace "$expression", "$replacement"}
		}
		Else	#write-host "I´m in a pipe"
		{
			ForEach( $line in ($input | Out-String -Stream) )
			{	$line | ForEach-Object{$_ -replace "$expression", "$replacement"}	}
		}
	}
}

Function sha1( $file )
{
<#	.SYNOPSIS
		SHA1 cheksum calculator
#>
	chksum -file $file -algo "SHA1"
}

Function sha256( $file )
{
<#	.SYNOPSIS
		SHA256 cheksum calculator
#>
	chksum -file $file -algo "SHA256"
}

Function sha512( $file )
{
<#	.SYNOPSIS
		SHA512 cheksum calculator
#>
	chksum -file $file -algo "SHA512"
}

Function tail( )
{
<#	.SYNOPSIS
		Print only the tail of a file
	.DESCRIPTION
		Better, near unix-like, tail implementation
	.PARAMETER wait
		Fait for following input
	.EXAMPLE
		Print last lines of a textfile
		PS C:\> tail help.txt 10
	.EXAMPLE
		Print a textfile and wait for, and print, following output
		PS C:\> tail help.txt -wait
	.EXAMPLE
		Print a last lines of pipeline output
		PS C:\> ls | tail
#>
	If( $($args[0]) -eq "-help" )
	{
		Write-Host "usage: $($MyInvocation.MYCommand) [-wait] [<file>] <numLines>"
		return
	}
	ForEach( $arg in $args )
	{
		If( $arg -eq "-wait" )
		{	$wait = $true	}
	}
	$lines = 20
	If( $args[0] )
	{
		If( !$(Test-Path $args[$($args.count-1)]) )
		{
			if( ($args[$($args.count-1)]).GetType().Name -ne "String" )
			{	$lines = $args[$($args.count-1)]	}
		}
		If( Test-Path $args[0] )	#write-host "I got a file"
		{
			$filename = $args[0]
			If( $wait )
			{	Get-Content $filename -Wait	}
			Else
			{	Get-Content $filename | Select-Object -Last $lines	}
			return
		}
	}
	If( $input )	#write-host "I´m in a pipe"
	{	$input | Out-String -Stream | Select-Object -Last $lines	}
}

Function time( )
{
<#	.SYNOPSIS
		Measure the runtime of a command
	.DESCRIPTION
		Better, near unix-like, time implementation
	.EXAMPLE
		Simple time measuring with parameter(s)
		PS C:\> time sleep 10
#>
	If( !$args[0] )
	{	Write-Host "usage: $($MyInvocation.MYCommand) <path/command> [<param1>...<paramN>]"	}
	Else
	{
		For( $index=0; $index -lt $($args.count); $index++ )
		{
			$command += $args[$index]
			$command += " "
		}
		Measure-Command { $command }
	}
}

Function top( [Switch]$wmi, $numProc=30, $seconds=2 )
{
<#	.SYNOPSIS
		List processes by cpu usage
	.DESCRIPTION
		Better, near unix-like, top implementation
	.EXAMPLE
		Percentual cpu usage
		PS C:\> top -wmi
#>
	Clear
	while( $true )
	{
		if( $host.ui.RawUi.KeyAvailable )
		{
			$key = $host.ui.RawUI.ReadKey( "NoEcho,IncludeKeyUp,IncludeKeyDown" )
			if( $key.VirtualKeyCode -eq 27 )
			{	break	}
		}
		[Console]::SetCursorPosition( 0, 0 )
		If( !$wmi )
		{	Get-Process | Sort-Object -Descending cpu | Select-Object -First $numProc	}
		Else
		{
			Get-WmiObject Win32_PerfFormattedData_PerfProc_Process | Sort-Object PercentProcessorTime -Descending | `
					Select-Object -First $numProc | Format-Table CreatingProcessID,IDProcess,PercentProcessorTime,`
							Name,ElapsedTime,PageFileBytes,WorkingSet,VirtualBytes -AutoSize
		}
		Sleep -Seconds $seconds
	}
}

Function touch( [Parameter(Mandatory=$true)][String]$path )
{
<#	.SYNOPSIS
		Create an empty file
	.DESCRIPTION
		Better, near unix-like, touch implementation
	.PARAMETER path
		Path of the new file
#>
	If( ! $(Test-Path $path) )
	{	New-Item $path -type "file"	}
	Else
	{	Write-Host "$path already exists"	}
}

Function uname( )
{
<#	.SYNOPSIS
		Display the os version
	.DESCRIPTION
		Better, near unix-like, uname implementation
#>
	[System.Environment]::OSVersion | Format-Table -AutoSize
}

Function uptime( )
{
<#	.SYNOPSIS
		Display the systems uptime
	.DESCRIPTION
		Better, near unix-like, uptime implementation
#>
	$bootTime = [System.Management.ManagementDateTimeconverter]::ToDateTime( `
				(Get-WmiObject win32_operatingSystem).LastBootupTime )
	$uptime = New-TimeSpan $bootTime $(get-date)
	Write-Host "$($uptime.Days) days " -NoNewLine
	Write-Host "$($uptime.Hours):$($uptime.Minutes):$($uptime.Seconds),$($uptime.Milliseconds)"
}

Function wc( )
{
<#	.SYNOPSIS
		Count chars, words, lines
	.DESCRIPTION
		Better, near unix-like, wc implementation
	.EXAMPLE
		Measure content of a textfile
		PS C:\> wc help.txt
	.EXAMPLE
		Measure stream in a pipe
		PS C:\> ls | wc
#>
	function New-Stat( )
	{
		param([string]$name)
		$stat = "" | Select-Object Lines, Words, Characters, Longest, Name
		$stat.Lines = $stat.Words = $stat.Characters = $stat.Longest = 0
		$stat.Name = $name
		$stat
	}
	If( $args[0] )
	{
		$stats = $null
		$stat_total = New-Stat -name "total"
		[System.IO.FileInfo[]]$files = Get-ChildItem $args[0] -ErrorAction SilentlyContinue | Where { $_.GetType().Name -eq "FileInfo" }
		If( $files -ne $null )
		{
			ForEach( $file in $files )
			{
				$stat = New-Stat -name "$file"
				[string[]]$content = Get-Content $file
				For( $i=0; $i -le $content.Length; $i++ )
				{
					$info = $content[$i] | Measure-Object -word -line -character
					$stat.Lines ++
					$stat.Words += $info.Words
					$stat.Characters += $info.Characters
				}
				$stat.lines --
				$stat_total.Characters += $stat.Characters;
				$stat_total.Lines += $stat.Lines;
				$stat_total.Words += $stat.Words;
				$stats += @($stat);
			}
			$stats += @($stat_total);
			$stats | Format-Table -AutoSize;
		}
	}
	Else
	{
		$stat = New-Stat -name "pipe"
		ForEach( $line in $input )
		{
			$info = $line | Measure-Object -word -line -character
			$stat.Lines ++
			$stat.Words += $info.Words
			$stat.Characters += $info.Characters
		}
		$stat | Format-Table -AutoSize;
	}
}

Function wget( $url=(Read-Host "Enter URL"), $fileName=$null, [Switch]$dump, [Switch]$quiet )
{
<#	.SYNOPSIS
		Downlaod a file from http
	.DESCRIPTION
		Better, near unix-like, wget implementation
#>
	$request = [System.Net.HttpWebRequest]::Create( $url )
	$response = $request.GetResponse( )
	If( $fileName -and !(Split-Path $fileName) )
	{	$fileName = Join-Path( Get-Location -PSProvider "FileSystem" ) $fileName	}
	ElseIf( (!$dump -and ($fileName -eq $null)) -or (($fileName -ne $null) -and (Test-Path -PathType "Container" $fileName)) )
	{
		[string]$fileName = ([regex]'(?i)filename=(.*)$').Match( $response.Headers["Content-Disposition"] ).Groups[1].Value
		$fileName = $fileName.trim( "\/""'" )
		If( !$fileName )
		{
			$fileName = $response.ResponseUri.Segments[-1]
			$fileName = $fileName.trim( "\/" )
			If( !$fileName )
			{	$fileName = Read-Host "Please provide a file name"	}
			$fileName = $fileName.trim( "\/" )
			If( !([IO.FileInfo]$fileName).Extension )
			{	$fileName = $fileName + "." + $response.ContentType.Split(";")[0].Split("/")[1]	}
		}
		$fileName = Join-Path( Get-Location -PSProvider "FileSystem" ) $fileName
	}
	If( $dump )
	{
		$encoding = [System.Text.Encoding]::GetEncoding( $response.CharacterSet )
		[string]$output = ""
	}
	If( $response.StatusCode -eq $([int][system.net.httpstatuscode]::ok) )
	{
		[int]$goal = $response.ContentLength
		$reader = $response.GetResponseStream( )
		If( $fileName )
		{	$writer = new-object System.IO.FileStream $fileName, "Create"	}
		[byte[]]$buffer = new-object byte[] 4096
		[int]$total = [int]$count = 0
		If( $goal -gt 0 )
		{	Write-Host "Downloading"  $("{0:N0}" -f $goal) "bytes from $url"	}
		Else
		{	Write-Host "Downloading from $url - Saving unknown size..."	}
		do{
			$count = $reader.Read( $buffer, 0, $buffer.Length )
			If( $fileName )
			{	$writer.Write( $buffer, 0, $count )	} 
			If( $dump )
			{	$output += $encoding.GetString($buffer,0,$count)	}
			ElseIf( !$quiet )
			{
				$total += $count
				If( $goal -gt 0 )
				{	Write-Host "`r$([int]$(($total/$goal)*100))% completed" -NoNewLine	}
				Else
				{	Write-Host "`r$(Date)" -NoNewLine	}
			}
		}while( $count -gt 0 )
		Write-Host
		$reader.Close( )
		If( $fileName )
		{
			$writer.Flush( )
			$writer.Close( )
		}
		If( $dump )
		{	$output	}
	}
	$response.Close( )
	If( $fileName )
	{
		If( $(Get-ChildItem $fileName) -and (($total/$goal) -eq 1) )
		{	Write-Host "Succesfully written" $("{0:N0}" -f $total) "bytes to $fileName"	}
	}
}

Function which( [String]$command )
{
<#	.SYNOPSIS
		Get information about alias, function or command
	.DESCRIPTION
		Better, near unix-like, which implementation
	.PARAMETER command
		The command for which information is wished about
#>
	$infos = Get-Command $command
	$infos
	ForEach( $info in $infos )
	{
		If( $info.CommandType -eq "Function" )
		{	
			Write-Host "`nContent of $($info.Name)():"
			For( $i = 0; $i -lt ($command.length + 14); $i++ )
			{	Write-Host -noNewLine "-"	}
			Write-Host
			$info.Definition
		}
	}
}

Function who( )
{
<#	.SYNOPSIS
		Get information about is logged in
	.DESCRIPTION
		Better, near unix-like, who implementation
#>
	Gwmi Win32_Computersystem -Comp "127.0.0.1" | Select Name, Domain, UserName, Workgroup
}

Function whois( [String]$domain, [String]$server="http://www.webservicex.net/whois.asmx?WSDL" )
{
<#	.SYNOPSIS
		Get information about domain name registration
	.DESCRIPTION
		Better, near unix-like, whois implementation
	.PARAMETER domain
		The domain of interrest
	.PARAMETER server
		The address/url of webservice
#>
	$webProxy = New-WebServiceProxy $server
	$answer = $webProxy.GetWhoIs("$domain")
	$last=$false
	ForEach( $line in $answer.Split("`r`n") )
	{
		If( !$last )
		{	$line	}
		If( $line.Contains(">>>") -and $line.Contains("<<<") )
		{	$last=$true	}
	}
}
