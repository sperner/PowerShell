# Registry
# wop...

param( [String]$command, [String]$fullPath, [String]$name, [String]$property, [String]$value )

$splitPath = $fullPath.split( '\' )

Switch( $splitPath[0] )
{
	"HKEY_CLASSES_ROOT"		{ $psdrive = "HKCR" }
	"HKEY_CURRENT_USER"		{ $psdrive = "HKCU" }
	"HKEY_LOCAL_MACHINE"	{ $psdrive = "HKLM" }
	"HKEY_USERS"			{ $psdrive = "HKU" }
	"HKEY_CURRENT_CONFIG"	{ $psdrive = "HKCC" }
	"HKEY_PERFORMANCE_DATA"	{ $psdrive = "HKPD" }
	"HKEY_DYN_DATA"			{ $psdrive = "HKDD" }
	default					{ Write-Host "Unknown hive: $($splitPath[0])"; exit -1 }
}

If( !(Get-PSDrive $psdrive) )
{	New-PSDrive -PSProvider registry -Root $splitPath[0] -Name $psdrive > $null			}

Switch( $command )
{
	"list"		{
					Get-ChildItem -Recurse "$($psdrive):" 2>$null | Select-Object `
						Name,SubKeyCount,ValueCount,PSChildName,Property | Format-Table
				}
	"search"	{
					If( $name -and $property )
					{	Get-ChildItem -Recurse "$($psdrive):" 2>$null | Where {($_.PSChildName -match $name) -and ($_.Property -match $property)}	}
					ElseIf( $name )
					{	Get-ChildItem -Recurse "$($psdrive):" 2>$null | Where {$_.PSChildName -match $name}		}
					ElseIf( $property )
					{	Get-ChildItem -Recurse "$($psdrive):" 2>$null | Where {$_.Property -match $property}	}
					Else
					{	Get-ChildItem -Recurse "$($psdrive):" 2>$null	}
				}
	"print"		{
					If( !$name )
					{	Get-ItemProperty -Path $fullPath	}
					Else
					{	Get-ItemProperty -Path $fullPath | Where {$_ -match $name}	}
				}
	"edit"		{
					Set-ItemProperty -Path $fullPath -Name $name -Value $value
				}
	"create"	{
					New-ItemProperty -Path $fullPath -Name $name -Value $value
				}
	default		{	Write-Host "Unknown command: $command"; exit -1	}
}
