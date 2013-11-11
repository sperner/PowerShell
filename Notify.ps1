# Print something in notification area
#

param( [String]$text="no text was passed", [String]$title="For your interest" )

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon 

$objNotifyIcon.Icon = "$env:windir\CmdFSC\nobugs.ico"
$objNotifyIcon.BalloonTipIcon = "Info" 
$objNotifyIcon.BalloonTipText = "$text" 
$objNotifyIcon.BalloonTipTitle = "$title" 

$objNotifyIcon.Visible = $True 
$objNotifyIcon.ShowBalloonTip(10000)
