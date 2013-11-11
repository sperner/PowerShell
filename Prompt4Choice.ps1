# Example of a PromptForChoice
#

$title = "Install a virus?"
$message = "Do you want to install an unremovable virus on your system?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Installs an unremovable virus on your system."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Leaves you the choice to ask your mama."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
{
	0 {
		Write-Host "The unremovable extremely destroying virus is going to be installed..."
		chkdsk > $null
		break
	}
	1 {
		$ie = New-Object -comObject InternetExplorer.Application
		$ie.navigate('http://www.askyourmama.com')
		$ie.visible = $true
		break
	}
}
