# Get protocols from "services" file
#
# usage:
#		to be sourced in powershell (:> . GetServices.ps1)
#

function Get-Protocol            
{            
	# CmdletBinding points to a parameter set with no parameters, 'All'.
	# Using this trick, it's possible to have a good default behavior with
	# no parameters without complex parameter guessing logic
	[CmdletBinding(DefaultParameterSetName='All')]

	param(
	# Get a named protocol
	[Parameter(Mandatory=$true, Position='0', ValueFromPipelineByPropertyName=$true, ParameterSetName='SpecificProtocols')]
	[Alias('Name')]
	[String[]]$Protocol,
	# Get protocols on a port
	[Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='SpecificPorts')]
	[int[]]$Port,
	# Only return TCP protocols
	[switch]$OnlyTCP,
	# Only return UDP protocols
	[switch]$OnlyUDP
	)

    #region Parse Services File
    begin {
		$servicesFilePath = "$env:windir\System32\drivers\etc\services"            
		# <service name>  <port number>/<protocol>  [aliases...]   [#<comment>]            
		$lines = [IO.File]::ReadAllText("$env:windir\System32\drivers\etc\services") -split
		# filter out all comment lines
		([Environment]::NewLine) -notlike "#*"

        $protocols = foreach ($line in $lines)
		{            
			# not empty lines
			if (-not $line) { continue }             

			# split lines into name, port+proto, alias+comment
			$serviceName, $portAndProtocol, $aliasesAndComments = $line.Split(' ', [StringSplitOptions]'RemoveEmptyEntries')
			# split port+proto into port, proto
			$portNumber, $protocolName = $portAndProtocol.Split("/")            
			# filter alias+comment into alias
			$aliases = @($aliasesAndComments) -notlike "#*"             
			# filter alias+comment into comment
			$comments =  @($aliasesAndComments) -like "#*"            
			# combine them in a PSObject
			$result = New-Object PSObject -Property @{
				ServiceName = $serviceName
				Port = $portNumber
				Protocol = $protocolName
				Aliases = $aliases
				Comments = $comments
			}

			# hidden typename to make formatting work
			$result.PSObject.TypeNames.add("Network.Protocol")
			$result
		}
	}
    #endregion            

    #region Process Input
    process {
		$filter = $null
		if ($OnlyTCP) {
			$filter = { $_.Protocol -eq 'TCP' }
		} elseif ($OnlyUDP) {
			$filter = { $_.Protocol -eq 'UDP' }
		}

		# By checking to see if the filter is defined,
		# we can save time and not filter
		if ($Filter) {
			$filtererdProtocols = $protocols | Where-Object $filter            
		} else {
			$filtererdProtocols = $protocols
		}

		# If the Parameter Set is "All", we output all of the protocols
		if ($psCmdlet.ParameterSetName -eq 'All')
		{
			Write-Output $filtererdProtocols
		} elseif ($psCmdlet.ParameterSetName -eq 'SpecificPorts') {
			# Otherwise, if we're looking for ports, we add another Where-Object
			# to find ports, and output that.
			$filtererdProtocols | Where-Object {
					$Port -contains $_.Port
				} | Write-Output
		} elseif ($psCmdlet.ParameterSetName -eq 'SpecificProtocols') {
			# Otherwise, if we're looking for protcols, we add another Where-Object
			# to find ports, and output that.
			$filtererdProtocols | Where-Object {
					$Protocol -contains $_.ServiceName
				}| Write-Output
		}                        
	}                  
	#endregion            
}
