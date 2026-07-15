param(
  [string]$CsvPath = "$PSScriptRoot\..\data\family_tree.csv",
  [string]$OutPath = "$PSScriptRoot\..\supabase\seed_family.sql"
)

$maxCol = 14
$nodes = [ordered]@{}
$siblingOrder = @{}
$currentKeys = @{}
$lastRowCols = @()
$lastVerticalParent = @{}

function Clean([string]$s) {
  if ([string]::IsNullOrWhiteSpace($s)) { return "" }
  return ($s.Trim() -replace "\s+", " ")
}

function NormalizePatriarch([string]$name) {
  $n = Clean $name
  if (-not $n) { return "" }
  if ($n -match '^(SH\.?\s*YONIS|SHEEKH\s+YONIS)$') { return "SHEEKH YONIS" }
  return $n
}

function Slug([string]$name) {
  $n = $name.ToLower() -replace "[^a-z0-9]+", "_"
  return $n.Trim("_")
}

function DeterministicUuid([string]$key) {
  $md5 = [System.Security.Cryptography.MD5]::Create()
  $hash = $md5.ComputeHash([Text.Encoding]::UTF8.GetBytes("reer_sh_yoonis:$key"))
  $hex = -join ($hash | ForEach-Object { $_.ToString("x2") })
  return "{0}-{1}-{2}-{3}-{4}" -f `
    $hex.Substring(0, 8), `
    $hex.Substring(8, 4), `
    $hex.Substring(12, 4), `
    $hex.Substring(16, 4), `
    $hex.Substring(20, 12)
}

function Ensure([string]$name, [string]$parentKey, [int]$gen) {
  $name = Clean $name
  if (-not $name) { return $null }
  if ($gen -eq 0) { $name = NormalizePatriarch $name }

  $base = Slug $name
  $key = $base
  $i = 2
  while ($nodes.Contains($key)) {
    $existing = $nodes[$key]
    if ($existing.parent -eq $parentKey) { return $key }
    $key = "${base}_$i"
    $i++
  }

  $orderKey = if ($parentKey) { $parentKey } else { "__root__" }
  if (-not $siblingOrder.Contains($orderKey)) { $siblingOrder[$orderKey] = 0 }
  $birthOrder = $siblingOrder[$orderKey]
  $siblingOrder[$orderKey] = $birthOrder + 1

  $nodes[$key] = @{
    name = $name
    parent = $parentKey
    gen = $gen
    id = (DeterministicUuid $key)
    birth_order = $birthOrder
  }
  return $key
}

function ParseCells([string]$line) {
  $raw = $line -split ',', ($maxCol + 1)
  $cells = @()
  for ($i = 0; $i -le $maxCol; $i++) {
    if ($i -lt $raw.Count) { $cells += $raw[$i] } else { $cells += "" }
  }
  return $cells
}

function Clear-CurrentFrom([int]$fromCol) {
  for ($j = $fromCol; $j -le $maxCol; $j++) {
    if ($currentKeys.ContainsKey($j)) { $currentKeys.Remove($j) }
  }
}

function Row-FilledCols([string[]]$cells) {
  $filled = @()
  for ($i = 0; $i -le $maxCol; $i++) {
    if (Clean $cells[$i]) { $filled += $i }
  }
  return ,$filled
}

function Resolve-VerticalParent([int]$col) {
  $onlyThisCol = ($lastRowCols.Count -eq 1 -and $lastRowCols[0] -eq $col)
  if ($onlyThisCol -and $lastVerticalParent.ContainsKey($col)) {
    return $lastVerticalParent[$col]
  }

  $branchHeader = ($lastRowCols -contains 0) -or ($lastRowCols -contains 1)
  if ($branchHeader -and $currentKeys.ContainsKey($col - 1)) {
    return $currentKeys[$col - 1]
  }

  if (($lastRowCols -contains ($col - 1)) -and ($lastRowCols -contains $col) -and $currentKeys.ContainsKey($col)) {
    return $currentKeys[$col]
  }

  for ($p = $col - 1; $p -ge 1; $p--) {
    if ($currentKeys.ContainsKey($p)) { return $currentKeys[$p] }
  }

  return $null
}

$lines = Get-Content -Path $CsvPath -Encoding UTF8
if ($lines.Count -lt 2) {
  throw "CSV must include a header row and at least one data row."
}

foreach ($line in $lines[1..($lines.Count - 1)]) {
  if ([string]::IsNullOrWhiteSpace($line)) { continue }
  $cells = ParseCells $line
  $rowCols = Row-FilledCols $cells

  $gp = NormalizePatriarch (Clean $cells[0])
  if ($gp) {
    $currentKeys[0] = Ensure $gp $null 0
    Clear-CurrentFrom 1
  }

  $uncle = Clean $cells[1]
  if ($uncle) {
    $gpKey = $currentKeys[0]
    if (-not $gpKey) {
      $gpKey = Ensure "SHEEKH YONIS" $null 0
      $currentKeys[0] = $gpKey
    }
    $uncleKey = Ensure $uncle $gpKey 1
    $currentKeys[0] = $gpKey
    $currentKeys[1] = $uncleKey
    Clear-CurrentFrom 2
  }

  if (-not $currentKeys.ContainsKey(1)) {
    $lastRowCols = $rowCols
    continue
  }

  $uncleKey = $currentKeys[1]
  $rowParentKeys = @{ 1 = $uncleKey }

  for ($col = 2; $col -le $maxCol; $col++) {
    $val = Clean $cells[$col]
    if (-not $val) { continue }

    if ($col -eq 2) {
      $parentKey = $uncleKey
    }
    elseif ($rowParentKeys.ContainsKey(2) -and (Clean $cells[2])) {
      # One row per child of the uncle: col 3+ are siblings under the name in col 2
      # (e.g. CISMAAN -> C/QADIR, YOONIS, MARWA ... not a chain).
      $parentKey = $rowParentKeys[2]
      $lastVerticalParent.Remove($col) | Out-Null
    }
    elseif (-not (Clean $cells[2]) -and $currentKeys.ContainsKey(2) -and $col -ge 3) {
      # Vertical continuation rows (col 3 only): siblings under the child in col 2
      # (e.g. C/RAHIM -> FARAH, FILSAN, FARHIYA ... on separate lines).
      $parentKey = $currentKeys[2]
      $lastVerticalParent.Remove($col) | Out-Null
    }
    elseif (Clean $cells[$col - 1]) {
      $parentKey = $rowParentKeys[$col - 1]
      $lastVerticalParent.Remove($col) | Out-Null
    }
    else {
      $parentKey = Resolve-VerticalParent $col
      if (-not $parentKey) { continue }
      $lastVerticalParent[$col] = $parentKey
    }

    $key = Ensure $val $parentKey $col
    $rowParentKeys[$col] = $key
    $currentKeys[$col] = $key
    Clear-CurrentFrom ($col + 1)
  }

  $lastRowCols = $rowCols
}

if (-not $currentKeys.ContainsKey(0)) {
  Ensure "SHEEKH YONIS" $null 0 | Out-Null
}

function SqlEscape([string]$s) {
  return $s -replace "'", "''"
}

$out = @()
$out += "-- Reer Sh Yoonis family tree seed (from SHEEK YOONIS CSV)"
$out += "-- Run after 001_initial_schema.sql and 016_profile_birth_order.sql"
$out += "BEGIN;"
$out += ""
$out += "-- Insert all profiles"
foreach ($entry in $nodes.GetEnumerator()) {
  $id = $entry.Value.id
  $name = SqlEscape $entry.Value.name
  $birthOrder = $entry.Value.birth_order
  $out += "INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)"
  $out += "VALUES ('$id', '$name', NULL, 'family_member', 'adult', 2, $birthOrder)"
  $out += "ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;"
}
$out += ""
$out += "-- Link father_id (lineage) - re-run this file to fix broken tree connections"
foreach ($entry in $nodes.GetEnumerator()) {
  $id = $entry.Value.id
  $parent = $entry.Value.parent
  if ($parent) {
    $parentId = $nodes[$parent].id
    $out += "UPDATE reer_sh_yoonis.profiles SET father_id = '$parentId' WHERE id = '$id';"
  }
}
$out += ""
$out += "-- Patriarch gets stable flourishing rating"
$out += "UPDATE reer_sh_yoonis.profiles SET care_rating = 1 WHERE full_name ILIKE 'SHEEKH YONIS';"
$out += ""
$out += "COMMIT;"
$out += ""
$out += "-- Total profiles seeded: $($nodes.Count)"

$out | Set-Content -Path $OutPath -Encoding UTF8
Write-Host "Wrote $($nodes.Count) profiles to $OutPath"
