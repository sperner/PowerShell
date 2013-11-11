# Simple checksum calculator
#
# available algorithms ($algo): md5, sha1, sha256, sha512
#

param( $file, $algo="MD5" )
 
$algo = [System.Security.Cryptography.HashAlgorithm]::Create( $algo )
$stream = New-Object System.IO.FileStream( $file, [System.IO.FileMode]::Open )
 
$stringBuilder = New-Object System.Text.StringBuilder
$algo.ComputeHash($stream) | % { [void] $stringBuilder.Append($_.ToString("x2")) }
$stringBuilder.ToString()
 
$stream.Dispose()
