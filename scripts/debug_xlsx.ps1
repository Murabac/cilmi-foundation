$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$xlsx = 'c:\Users\lappybooks\Downloads\SHEEK YOONIS - FINAL(1).xlsx'
$tmp = Join-Path $env:TEMP 'rsy_dbg2'
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
New-Item -ItemType Directory -Path $tmp | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($xlsx, $tmp)

[xml]$sheet = Get-Content (Join-Path $tmp 'xl\worksheets\sheet1.xml') -Raw
$ns = New-Object System.Xml.XmlNamespaceManager($sheet.NameTable)
$ns.AddNamespace('x', 'http://schemas.openxmlformats.org/spreadsheetml/2006/main')

$xmlRows = $sheet.SelectNodes('//x:sheetData/x:row', $ns)
Write-Host "XML rows: $($xmlRows.Count)"
Write-Host "First row r=$($xmlRows[0].r) cells=$($xmlRows[0].SelectNodes('x:c',$ns).Count)"
Write-Host "Last row r=$($xmlRows[$xmlRows.Count-1].r)"

$rowNums = @()
foreach ($row in $xmlRows) { $rowNums += [int]$row.r }
Write-Host "Min row: $(($rowNums | Measure-Object -Minimum).Minimum) Max row: $(($rowNums | Measure-Object -Maximum).Maximum)"

$sheekh = 0
foreach ($row in $xmlRows) {
  foreach ($cell in $row.SelectNodes('x:c', $ns)) {
    if ($cell.t -eq 's' -and $cell.v -eq '4') { $sheekh++ }
  }
}
Write-Host "Cells referencing shared string index 4 (SH. YONIS): $sheekh"
