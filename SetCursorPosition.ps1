# Set mouse cursor
#

param( $x, $y )

Add-Type -AssemblyName System.Windows.Forms

If( !$x -OR !$y )
{	$screen = [System.Windows.Forms.SystemInformation]::VirtualScreen	}

If( !$x )
{	$x = $screen.Width	}
If( !$y )
{	$y = $screen.Height	}

[Windows.Forms.Cursor]::Position = "$x,$y" 
