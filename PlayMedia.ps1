# Play any media file
#

param( $path )

# Use the default player to play. Hide the window.
$startInfo = new-object System.Diagnostics.ProcessStartInfo
$startInfo.fileName = $path
$startInfo.windowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
$process = New-Object System.Diagnostics.Process
$process.startInfo = $startInfo
$process.start( )
