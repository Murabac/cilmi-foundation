$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\generate_seed.ps1" -CsvPath "$PSScriptRoot\..\data\family_tree.csv" -OutPath "$env:TEMP\rsy_v.sql" | Out-Null

# Re-parse by invoking generate_seed which sets $nodes - need to duplicate minimal parse output
$CsvPath = "$PSScriptRoot\..\data\family_tree.csv"
$maxCol = 14
$nodes = [ordered]@{}
$siblingOrder = @{}
$currentKeys = @{}
$lastRowCols = @()
$lastVerticalParent = @{}

function Clean([string]$s) { if ([string]::IsNullOrWhiteSpace($s)) { return "" }; return ($s.Trim() -replace "\s+", " ") }
function NormalizePatriarch([string]$name) { $n = Clean $name; if (-not $n) { return "" }; if ($n -match '^(SH\.?\s*YONIS|SHEEKH\s+YONIS)$') { return "SHEEKH YONIS" }; return $n }
function Slug([string]$name) { ($name.ToLower() -replace "[^a-z0-9]+", "_").Trim("_") }
function ParseCells([string]$line) { $raw = $line -split ',', ($maxCol + 1); $cells = @(); for ($i = 0; $i -le $maxCol; $i++) { if ($i -lt $raw.Count) { $cells += $raw[$i] } else { $cells += "" } }; return $cells }
function Clear-CurrentFrom([int]$fromCol) { for ($j = $fromCol; $j -le $maxCol; $j++) { if ($currentKeys.ContainsKey($j)) { $currentKeys.Remove($j) | Out-Null } } }
function Row-FilledCols([string[]]$cells) { $filled = @(); for ($i = 0; $i -le $maxCol; $i++) { if (Clean $cells[$i]) { $filled += $i } }; return ,$filled }
function Resolve-VerticalParent([int]$col) {
  $onlyThisCol = ($lastRowCols.Count -eq 1 -and $lastRowCols[0] -eq $col)
  if ($onlyThisCol -and $lastVerticalParent.ContainsKey($col)) { return $lastVerticalParent[$col] }
  $branchHeader = ($lastRowCols -contains 0) -or ($lastRowCols -contains 1)
  if ($branchHeader -and $currentKeys.ContainsKey($col - 1)) { return $currentKeys[$col - 1] }
  if (($lastRowCols -contains ($col - 1)) -and ($lastRowCols -contains $col) -and $currentKeys.ContainsKey($col)) { return $currentKeys[$col] }
  for ($p = $col - 1; $p -ge 1; $p--) { if ($currentKeys.ContainsKey($p)) { return $currentKeys[$p] } }
  return $null
}
function Ensure([string]$name, [string]$parentKey, [int]$gen) {
  $name = Clean $name; if (-not $name) { return $null }; if ($gen -eq 0) { $name = NormalizePatriarch $name }
  $base = Slug $name; $key = $base; $i = 2
  while ($nodes.Contains($key)) { if ($nodes[$key].parent -eq $parentKey) { return $key }; $key = "${base}_$i"; $i++ }
  $orderKey = if ($parentKey) { $parentKey } else { "__root__" }
  if (-not $siblingOrder.ContainsKey($orderKey)) { $siblingOrder[$orderKey] = 0 }
  $birthOrder = $siblingOrder[$orderKey]; $siblingOrder[$orderKey] = $birthOrder + 1
  $nodes[$key] = @{ name = $name; parent = $parentKey; gen = $gen; birth_order = $birthOrder }; return $key
}

$lines = Get-Content -Path $CsvPath -Encoding UTF8
foreach ($line in $lines[1..($lines.Count - 1)]) {
  if ([string]::IsNullOrWhiteSpace($line)) { continue }
  $cells = ParseCells $line; $rowCols = Row-FilledCols $cells
  $gp = NormalizePatriarch (Clean $cells[0]); if ($gp) { $currentKeys[0] = Ensure $gp $null 0; Clear-CurrentFrom 1 }
  $uncle = Clean $cells[1]; if ($uncle) { $gpKey = $currentKeys[0]; if (-not $gpKey) { $gpKey = Ensure "SHEEKH YONIS" $null 0; $currentKeys[0] = $gpKey }; $uncleKey = Ensure $uncle $gpKey 1; $currentKeys[0] = $gpKey; $currentKeys[1] = $uncleKey; Clear-CurrentFrom 2 }
  if (-not $currentKeys.ContainsKey(1)) { $lastRowCols = $rowCols; continue }
  $uncleKey = $currentKeys[1]; $rowParentKeys = @{ 1 = $uncleKey }
  for ($col = 2; $col -le $maxCol; $col++) {
    $val = Clean $cells[$col]; if (-not $val) { continue }
    if ($col -eq 2) { $parentKey = $uncleKey }
    elseif ($rowParentKeys.ContainsKey(2) -and (Clean $cells[2])) { $parentKey = $rowParentKeys[2]; $lastVerticalParent.Remove($col) | Out-Null }
    elseif (Clean $cells[$col - 1]) { $parentKey = $rowParentKeys[$col - 1]; $lastVerticalParent.Remove($col) | Out-Null }
    else { $parentKey = Resolve-VerticalParent $col; if (-not $parentKey) { continue }; $lastVerticalParent[$col] = $parentKey }
    $key = Ensure $val $parentKey $col; $rowParentKeys[$col] = $key; $currentKeys[$col] = $key; Clear-CurrentFrom ($col + 1)
  }
  $lastRowCols = $rowCols
}

function ParentName($key) { if (-not $key -or -not $nodes[$key].parent) { return '' }; return $nodes[$nodes[$key].parent].name }
function ChainName($key) {
  $parts = @($nodes[$key].name); $cur = $key; $seen = @{}
  while ($nodes[$cur].parent) {
    if ($seen[$cur]) { return 'CYCLE'; break }
    $seen[$cur] = $true
    $cur = $nodes[$cur].parent
    $parts = @($nodes[$cur].name) + $parts
  }
  return $parts -join ' -> '
}

Write-Host '=== Vertical col-3-only rows (possible sibling chains) ==='
$lineNum = 1
foreach ($line in $lines[1..($lines.Count - 1)]) {
  $lineNum++
  if ([string]::IsNullOrWhiteSpace($line)) { continue }
  $cells = ParseCells $line
  $filled = Row-FilledCols $cells
  if ($filled.Count -eq 1 -and $filled[0] -eq 3) {
    $name = Clean $cells[3]
    Write-Host "  Line $lineNum : $name -> $(ChainName ($nodes[(Slug $name)]))"
  }
}

Write-Host ''
Write-Host '=== Branch header col2+col3 (second name may be sibling or child) ==='
$lineNum = 1
foreach ($line in $lines[1..($lines.Count - 1)]) {
  $lineNum++
  if ([string]::IsNullOrWhiteSpace($line)) { continue }
  $cells = ParseCells $line
  if ((Clean $cells[1]) -and (Clean $cells[2]) -and (Clean $cells[3]) -and -not (Clean $cells[4])) {
    $c2 = Clean $cells[2]; $c3 = Clean $cells[3]; $uncle = Clean $cells[1]
    $k3 = $nodes[(Slug $c3)]
    if (-not $k3) { $i=2; while (-not $k3 -and $nodes.Contains("${((Slug $c3))}_$i")) { $k3 = $nodes["${((Slug $c3))}_$i"]; $i++ } }
    $pn = ParentName $k3
    Write-Host "  Line $lineNum ($uncle): $c2, $c3 -> parent of $c3 is $pn"
  }
}
