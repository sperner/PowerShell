# Simple Text-2-Speech
#

#param( [Parameter(ValueFromPipeline=$true)][string] $say )

$voice = New-Object -ComObject SAPI.SPVoice
$voice.Rate = -4

if( $args )
{
	if( Test-Path $args[0] )	# Speak out file content
	{
		ForEach( $line in Get-Content $args[0] )
		{
			$voice.Speak( $line ) | out-null
		}
	}
	else	# Speak out command line arguments
	{
		$voice.Speak( $args ) | out-null
	}
}

if( $input )	# Speak out values from pipeline
{
	ForEach( $say in $input )
	{
		$voice.Speak( $say ) | out-null
	}
}
