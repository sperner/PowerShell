# Example of using a progressbar
# (calculating sum of all .dll files under C:\WIN)

$colFiles = Get-ChildItem C:\WIN -include *.dll -recurse

foreach ($objFile in $colFiles)
{
	$i++
	$intSize = $intSize + $objFile.Length
	Write-Progress -activity "Adding File Sizes" -status "Percent added: " `
				-PercentComplete (($i / $colFiles.length)  * 100)

}

$intSize = "{0:N0}" -f $intSize

Write-Host "Total size of .DLL files: $intSize bytes."

