# Read an .ini configuration file given as parameter ($confFile/args[0])
#
# example of .ini content:
# [section]
# option=value
#

param ($confFile)

if( $confFile )
{
	$confTable = @{}
	switch -regex -file $confFile
	{
		 "^\[(.+)\]$" {
		 $confSection = $matches[1]
		 $confTable[$confSection] = @{} 
		 }
		 "(.+)=(.+)" {
		 $confName,$confValue = $matches[1..2]
		 $confTable[$confSection][$confName] = $confValue
		 }
	}
	$confTable
}