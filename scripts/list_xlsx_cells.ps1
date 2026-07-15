$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$xlsx = "$env:USERPROFILE\Downloads\SHEEK YOONIS - FINAL(1).xlsx"
$tmp = Join-Path $env:TEMP 'rsy_allcells'
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
New-Item -ItemType Directory -Path $tmp | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($xlsx, $tmp)

[xml]$sharedDoc = Get-Content (Join-Path $tmp 'xl\sharedStrings.xml') -Raw -Encoding UTF8
$shared = @()
foreach ($si in $sharedDoc.sst.si) {
  if ($si.t) { $shared += $si.t.InnerText }
  elseif ($si.r) {
    $parts = @(); foreach ($run in @($si.r)) { if ($run.t) { $parts += $run.t.InnerText } }
    $shared += ($parts -join '')
  } else { $shared += '' }
}

foreach ($sheetName in @('sheet1.xml', 'sheet2.xml')) {
  $path = Join-Path $tmp "xl\worksheets\$sheetName"
  if (-not (Test-Path $path)) { continue }
  [xml]$sheetDoc = Get-Content $path -Raw -Encoding UTF8
  $ns = New-Object System.Xml.XmlNamespaceManager($sheetDoc.NameTable)
  $ns.AddNamespace('x', 'http://schemas.openxmlformats.org/spreadsheetml/2006/main')
  $cells = $sheetDoc.SelectNodes('//x:sheetData//x:c', $ns)
  Write-Host "=== $sheetName cells: $($cells.Count) ==="
  $shown = 0
  foreach ($cell in $cells) {
    $val = ''
    if ($cell.t -eq 's') { $val = $shared[[int]$cell.v] }
    elseif ($cell.v) { $val = [string]$cell.v }
    elseif ($cell.is) {
      $ts = $cell.SelectNodes('x:is//x:t', $ns)
      if ($ts) { $val = (($ts | ForEach-Object { $_.InnerText }) -join '') }
    }
    if ($val) {
      Write-Host "$($cell.r): $val"
      $shown++
      if ($shown -ge 40) { Write-Host '...'; break }
    }
  }
}

Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
