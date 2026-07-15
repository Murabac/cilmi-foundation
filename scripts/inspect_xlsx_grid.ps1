$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$xlsx = "$env:USERPROFILE\Downloads\SHEEK YOONIS - FINAL(1).xlsx"
$tmp = Join-Path $env:TEMP ("rsy_grid_" + [guid]::NewGuid().ToString('N'))
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

[xml]$sheetDoc = Get-Content (Join-Path $tmp 'xl\worksheets\sheet1.xml') -Raw -Encoding UTF8
$ns = New-Object System.Xml.XmlNamespaceManager($sheetDoc.NameTable)
$ns.AddNamespace('x', 'http://schemas.openxmlformats.org/spreadsheetml/2006/main')

function ColIndex([string]$letters) {
  $n = 0
  foreach ($ch in $letters.ToCharArray()) {
    if ($ch -lt 'A' -or $ch -gt 'Z') { continue }
    $n = ($n * 26) + ([int][char]$ch - [int][char]'A' + 1)
  }
  return $n
}

$grid = @{}
foreach ($row in $sheetDoc.SelectNodes('//x:sheetData/x:row', $ns)) {
  $rowNum = [int]$row.r
  foreach ($cell in $row.SelectNodes('x:c', $ns)) {
    $ref = $cell.r
    $letters = ($ref -replace '[^A-Z]', '')
    $col = ColIndex $letters
    $val = ''
    if ($cell.t -eq 's') { $val = $shared[[int]$cell.v] }
    elseif ($cell.v) { $val = [string]$cell.v }
    if ($val) { $grid["$rowNum,$col"] = $val.Trim() }
  }
}

Write-Host "Grid cells with values: $($grid.Count)"
Write-Host "--- Rows 1-25, cols 1-15 ---"
for ($r = 1; $r -le 25; $r++) {
  $parts = @()
  for ($c = 1; $c -le 15; $c++) {
    $key = "$r,$c"
    if ($grid.ContainsKey($key)) { $parts += $grid[$key] } else { $parts += '.' }
  }
  Write-Host ("{0,3}: {1}" -f $r, ($parts -join ' | '))
}

Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
