param(
  [string]$XlsxPath = "$env:USERPROFILE\Downloads\SHEEK YOONIS - FINAL(1).xlsx",
  [string]$OutPath = "$PSScriptRoot\..\data\family_tree.csv",
  [int]$MaxCol = 14
)

$ErrorActionPreference = 'Stop'

function Clean([string]$s) {
  if ([string]::IsNullOrWhiteSpace($s)) { return '' }
  $s = ($s -replace '\s+', ' ').Trim()
  if ($s -match '^(SH\.?\s*YONIS|SHEEKH\s+YONIS)$') { return 'SHEEKH YONIS' }
  return $s
}

function ColLettersToIndex([string]$letters) {
  $n = 0
  foreach ($ch in $letters.ToCharArray()) {
    if ($ch -lt 'A' -or $ch -gt 'Z') { continue }
    $n = ($n * 26) + ([int][char]$ch - [int][char]'A' + 1)
  }
  return $n - 1
}

function Get-SharedStringText($si) {
  if ($null -eq $si) { return '' }
  if ($si.t) { return $si.t.InnerText }
  if ($si.r) {
    $parts = @()
    foreach ($run in @($si.r)) {
      if ($run.t) { $parts += $run.t.InnerText }
    }
    return ($parts -join '')
  }
  return ''
}

function Get-CellText($cell, $ns, $shared) {
  if ($null -eq $cell) { return '' }
  if ($cell.t -eq 's') {
    $idx = [int]$cell.v
    if ($idx -ge 0 -and $idx -lt $shared.Count) {
      return $shared[$idx]
    }
    return ''
  }
  if ($cell.v) { return [string]$cell.v }
  $inlineText = $cell.SelectNodes('x:is//x:t', $ns)
  if ($inlineText -and $inlineText.Count -gt 0) {
    return (($inlineText | ForEach-Object { $_.InnerText }) -join '')
  }
  return ''
}

function ParseCellRef([string]$ref) {
  $letters = ($ref -replace '[^A-Z]', '')
  $row = [int]($ref -replace '[^0-9]', '')
  return @{
    col = ColLettersToIndex $letters
    row = $row
  }
}

if (-not (Test-Path $XlsxPath)) {
  throw "Excel file not found: $XlsxPath"
}

$tmp = Join-Path $env:TEMP ("rsy_xlsx_" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::ExtractToDirectory($XlsxPath, $tmp)

  [xml]$sharedDoc = Get-Content (Join-Path $tmp 'xl\sharedStrings.xml') -Raw -Encoding UTF8
  $shared = @()
  foreach ($si in $sharedDoc.sst.si) {
    $shared += (Get-SharedStringText $si)
  }

  [xml]$sheetDoc = Get-Content (Join-Path $tmp 'xl\worksheets\sheet1.xml') -Raw -Encoding UTF8
  $ns = New-Object System.Xml.XmlNamespaceManager($sheetDoc.NameTable)
  $ns.AddNamespace('x', 'http://schemas.openxmlformats.org/spreadsheetml/2006/main')

  $rows = @{}
  foreach ($row in $sheetDoc.SelectNodes('//x:sheetData/x:row', $ns)) {
    $rowNum = [int]$row.r
    if (-not $rows.ContainsKey($rowNum)) {
      $rows[$rowNum] = @{}
    }
    foreach ($cell in $row.SelectNodes('x:c', $ns)) {
      $ref = ParseCellRef $cell.r
      $value = Get-CellText $cell $ns $shared
      $rows[$rowNum][$ref.col] = Clean $value
    }
  }

  if ($rows.Count -eq 0) {
    throw 'No rows found in sheet1.'
  }

  $maxRow = ($rows.Keys | Measure-Object -Maximum).Maximum
  $lines = New-Object System.Collections.Generic.List[string]
  $headerAdded = $false

  for ($r = 1; $r -le $maxRow; $r++) {
    if (-not $rows.ContainsKey($r)) { continue }
    $cells = @()
    for ($c = 0; $c -le $MaxCol; $c++) {
      if ($rows[$r].ContainsKey($c)) {
        $cells += $rows[$r][$c]
      }
      else {
        $cells += ''
      }
    }

    $first = Clean $cells[0]
    $second = Clean $cells[1]
    if ($first -eq 'GRANDPARENT' -and $second -eq 'UNCLE') {
      if (-not $headerAdded) {
        $lines.Add(('GRANDPARENT,UNCLE,CHILD,GRANDCHILD,' + ((',' * ($MaxCol - 3)))))
        $headerAdded = $true
      }
      continue
    }

    $line = ($cells -join ',')
    if ($line -match '[^,]') {
      $lines.Add($line)
    }
  }

  if (-not $headerAdded) {
    $lines.Insert(0, ('GRANDPARENT,UNCLE,CHILD,GRANDCHILD,' + ((',' * ($MaxCol - 3)))))
  }

  $lines | Set-Content -Path $OutPath -Encoding UTF8
  Write-Host "Exported $($lines.Count - 1) data rows from $XlsxPath to $OutPath"
}
finally {
  if (Test-Path $tmp) {
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
  }
}
