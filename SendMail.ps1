# How to send a mail in fsc.net
# ...without parameter "-credential ..." windows-logon-user/pass are used - no popup to enter password!

#Send-MailMessage -to "MySelf <Sven.Sperner@ts.fujitsu.com>" -from "PowerShell <Sven.Sperner@ts.fujitsu.com>" `
# -subject "PowerShell-Mail-Test" -credential "DOMFSC01\ffmsperners" -smtpserver "ABGZE78E.FSC.NET"

# without password, with attachment
#Send-MailMessage -to "MySelf <Sven.Sperner@ts.fujitsu.com>" -from "PowerShell <Sven.Sperner@ts.fujitsu.com>" `
# -subject "PowerShell-Mail-AttachmentTest" -smtpserver "ABGZE78E.FSC.NET" -attachments "D:\text.txt"

# mail-server in "citrix-net"
#Send-MailMessage -to		"MySelf <Sven.Sperner@ts.fujitsu.com>" `
#		 -from		"IAAS Reporting <IAAS.Reporting-DoNotRreply@ts.fujitsu.com>" `
#		 -subject	"IAAS-Report" `
#		 -smtpserver	"smtp.smc.fsc.net" `
#		 -attachments	("C:\Dokumente und Einstellungen\Administrator\Desktop\Scripts\StatusList_2012-03-19*.csv"`
#				,"C:\Dokumente und Einstellungen\Administrator\Desktop\Scripts\StatusList_2012-03-19*.csv.summary.txt")
if( $args[0] )
{
	$attachments = @(get-childitem "$($args[0])" )
	Send-MailMessage -to	"MySelf <Sven.Sperner@ts.fujitsu.com>" `
		 -from		"SendMail-Script <SenMail-Script_DoNotRreply@ts.fujitsu.com>" `
		 -subject	"An attachment was sent" `
		 -bodyashtml	"Hello,<br/><br/>an attachment was appended.<br/><br/>Best regards" `
		 -smtpserver	"smtp.smc.fsc.net" `
		 -attachments	( $attachments )
}
else
{
	Send-MailMessage -to	"MySelf <Sven.Sperner@ts.fujitsu.com>" `
		 -from		"SendMail-Script <SenMail-Script_DoNotRreply@ts.fujitsu.com>" `
		 -subject	"Just a testmail" `
		 -bodyashtml	"Hello,<br/><br/>this is just a testmail.<br/>No files were attached.<br/><br/>Best regards" `
		 -smtpserver	"smtp.smc.fsc.net"
}
