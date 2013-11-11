$strComputer = “.”

$Excel = New-Object -Com Excel.Application
$Excel.visible = $True
$Excel = $Excel.Workbooks.Add()

$Sheet = $Excel.WorkSheets.Item(1)
$Sheet.Cells.Item(1,1) = “Computer”
$Sheet.Cells.Item(1,2) = “Drive Letter”
$Sheet.Cells.Item(1,3) = “Description”
$Sheet.Cells.Item(1,4) = “FileSystem”
$Sheet.Cells.Item(1,5) = “Size in GB”
$Sheet.Cells.Item(1,6) = “Free Space in GB”

$WorkBook = $Sheet.UsedRange
$WorkBook.Interior.ColorIndex = 8
$WorkBook.Font.ColorIndex = 11
$WorkBook.Font.Bold = $True

$intRow = 2
$colItems = Get-wmiObject -class “Win32_LogicalDisk” -namespace “root\CIMV2" -computername $strComputer

foreach ($objItem in $colItems) {
$Sheet.Cells.Item($intRow,1) = $objItem.SystemName
$Sheet.Cells.Item($intRow,2) = $objItem.DeviceID
$Sheet.Cells.Item($intRow,3) = $objItem.Description
$Sheet.Cells.Item($intRow,4) = $objItem.FileSystem
$Sheet.Cells.Item($intRow,5) = $objItem.Size / 1GB
$Sheet.Cells.Item($intRow,6) = $objItem.FreeSpace / 1GB

$intRow = $intRow + 1

}
$WorkBook.EntireColumn.AutoFit()
#Clear
