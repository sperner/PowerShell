# Simple HexDump
#

param( $path, $width=16, $bytes=-1 )

$OFS=""

if( !(Test-Path $path) )
{
	Write-Host "no file at $path"
	exit -1
}

if( $bytes -eq -1 )
{
	$bytes = (Get-Item $path).length
}

ForEach( $byte in Get-Content -Encoding byte $path -ReadCount $width -totalcount $bytes )
{
	if( ($byte -eq 0).count -ne $width )
	{
		$hex = $byte | Foreach-Object {
			" " + ("{0:x}" -f $_).PadLeft( 2, "0" )
		}
		$char = $byte | Foreach-Object {
			if( [char]::IsLetterOrDigit($_) )
			{
				[char] $_
			}
			else
			{
				"."
			}
		}
		"$hex $char"
	}
}
