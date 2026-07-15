param(
  [string]$CsvPath = "$PSScriptRoot\..\data\family_tree.csv",
  [string]$SeedPath = "$PSScriptRoot\..\supabase\seed_family.sql"
)

$ErrorActionPreference = 'Stop'
$maxCol = 14

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

function ParseCells([string]$line) {
  $raw = $line -split ',', ($maxCol + 1)
  $cells = @()
  for ($i = 0; $i -le $maxCol; $i++) {
    if ($i -lt $raw.Count) { $cells += $raw[$i] } else { $cells += "" }
  }
  return $cells
}

function Clear-CurrentFrom([hashtable]$currentKeys, [int]$fromCol) {
  for ($j = $fromCol; $j -le $maxCol; $j++) {
    if ($currentKeys.ContainsKey($j)) { $currentKeys.Remove($j) | Out-Null }
  }
}

function Row-FilledCols([string[]]$cells) {
  $filled = @()
  for ($i = 0; $i -le $maxCol; $i++) {
    if (Clean $cells[$i]) { $filled += $i }
  }
  return ,$filled
}

function Resolve-VerticalParent([int]$col, [int[]]$lastRowCols, [hashtable]$currentKeys, [hashtable]$lastVerticalParent) {
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

# --- Parse CSV with same rules as generate_seed.ps1 ---
$nodes = [ordered]@{}
$siblingOrder = @{}
$currentKeys = @{}
$lastRowCols = @()
$lastVerticalParent = @{}

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
    name       = $name
    parent     = $parentKey
    gen        = $gen
    birth_order = $birthOrder
  }
  return $key
}

$lines = Get-Content -Path $CsvPath -Encoding UTF8
foreach ($line in $lines[1..($lines.Count - 1)]) {
  if ([string]::IsNullOrWhiteSpace($line)) { continue }
  $cells = ParseCells $line
  $rowCols = Row-FilledCols $cells

  $gp = NormalizePatriarch (Clean $cells[0])
  if ($gp) {
    $currentKeys[0] = Ensure $gp $null 0
    Clear-CurrentFrom $currentKeys 1
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
    Clear-CurrentFrom $currentKeys 2
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
      $parentKey = $rowParentKeys[2]
      $lastVerticalParent.Remove($col) | Out-Null
    }
    elseif (Clean $cells[$col - 1]) {
      $parentKey = $rowParentKeys[$col - 1]
      $lastVerticalParent.Remove($col) | Out-Null
    }
    else {
      $parentKey = Resolve-VerticalParent $col $lastRowCols $currentKeys $lastVerticalParent
      if (-not $parentKey) { continue }
      $lastVerticalParent[$col] = $parentKey
    }

    $key = Ensure $val $parentKey $col
    $rowParentKeys[$col] = $key
    $currentKeys[$col] = $key
    Clear-CurrentFrom $currentKeys ($col + 1)
  }

  $lastRowCols = $rowCols
}

if (-not $nodes.Contains('sheekh_yonis')) {
  Ensure "SHEEKH YONIS" $null 0 | Out-Null
}

# --- Parse seed ---
$seed = Get-Content -Path $SeedPath -Raw
$inserts = [regex]::Matches($seed, "VALUES \('([^']+)', '([^']+)', NULL, 'family_member', 'adult', 2, (\d+)\)")
$idToName = @{}
$idToBirthOrder = @{}
foreach ($m in $inserts) {
  $idToName[$m.Groups[1].Value] = $m.Groups[2].Value
  $idToBirthOrder[$m.Groups[1].Value] = [int]$m.Groups[3].Value
}

$updates = [regex]::Matches($seed, "UPDATE reer_sh_yoonis.profiles SET father_id = '([^']+)' WHERE id = '([^']+)'")
$seedFatherOf = @{}
$seedChildren = @{}
foreach ($m in $updates) {
  $childId = $m.Groups[2].Value
  $parentId = $m.Groups[1].Value
  $seedFatherOf[$childId] = $parentId
  if (-not $seedChildren.ContainsKey($parentId)) { $seedChildren[$parentId] = @() }
  $seedChildren[$parentId] += $childId
}

function Get-Chain([hashtable]$fatherOf, [string]$id, [hashtable]$idToName) {
  $chain = @()
  $cur = $id
  $seen = @{}
  while ($fatherOf.ContainsKey($cur)) {
    if ($seen.ContainsKey($cur)) { return @('CYCLE') + $chain }
    $seen[$cur] = $true
    $cur = $fatherOf[$cur]
    $chain = @($idToName[$cur]) + $chain
  }
  return $chain
}

Write-Host '========== FAMILY TREE VALIDATION ==========' -ForegroundColor Cyan
Write-Host "CSV path: $CsvPath"
Write-Host "Seed path: $SeedPath"
Write-Host ''

# 1. Counts
Write-Host '--- Profile counts ---'
Write-Host "CSV parser profiles: $($nodes.Count)"
Write-Host "Seed profiles:       $($idToName.Count)"

# 2. Name coverage
$csvNames = @($nodes.Values | ForEach-Object { $_.name } | Sort-Object -Unique)
$seedNames = @($idToName.Values | Sort-Object -Unique)
$missingInSeed = @($csvNames | Where-Object { $_ -notin $seedNames })
$extraInSeed = @($seedNames | Where-Object { $_ -notin $csvNames })
Write-Host ''
Write-Host '--- Name coverage ---'
Write-Host "Missing in seed: $($missingInSeed.Count)"
$missingInSeed | ForEach-Object { Write-Host "  $_" }
Write-Host "Extra in seed:   $($extraInSeed.Count)"
$extraInSeed | ForEach-Object { Write-Host "  $_" }

# 3. Connectivity
$rootIds = @($idToName.GetEnumerator() | Where-Object { $_.Value -eq 'SHEEKH YONIS' } | ForEach-Object { $_.Key })
$broken = @()
foreach ($id in $idToName.Keys) {
  if ($id -in $rootIds) { continue }
  $cur = $id
  $seen = @{}
  $ok = $false
  while ($seedFatherOf.ContainsKey($cur)) {
    if ($seen.ContainsKey($cur)) { break }
    $seen[$cur] = $true
    $cur = $seedFatherOf[$cur]
    if ($cur -in $rootIds) { $ok = $true; break }
  }
  if (-not $ok) {
    $broken += [pscustomobject]@{
      name   = $idToName[$id]
      father = if ($seedFatherOf.ContainsKey($id)) { $idToName[$seedFatherOf[$id]] } else { '(none)' }
    }
  }
}
Write-Host ''
Write-Host '--- Connectivity to patriarch ---'
Write-Host "Disconnected profiles: $($broken.Count)"
$broken | Sort-Object name | Format-Table -AutoSize

# 4. Compare parent-child structure (CSV parser vs seed by name path)
# Build seed lookup: name+parentName -> id (handle dup names by parent context)
$seedByKey = @{}
foreach ($id in $idToName.Keys) {
  $name = $idToName[$id]
  $parentName = if ($seedFatherOf.ContainsKey($id)) { $idToName[$seedFatherOf[$id]] } else { '' }
  $k = "$parentName|$name"
  if ($seedByKey.ContainsKey($k)) {
    $seedByKey[$k] = @($seedByKey[$k]) + $id
  } else {
    $seedByKey[$k] = $id
  }
}

function Parent-Name([string]$nodeKey) {
  if (-not $nodeKey) { return '' }
  $p = $nodes[$nodeKey].parent
  if (-not $p) { return '' }
  return $nodes[$p].name
}

$parentMismatches = @()
$orderMismatches = @()
foreach ($entry in $nodes.GetEnumerator()) {
  $key = $entry.Key
  $node = $entry.Value
  $expectedParentName = Parent-Name $key
  $lookupKey = "$expectedParentName|$($node.name)"
  $seedMatch = $seedByKey[$lookupKey]

  if (-not $seedMatch) {
    $parentMismatches += [pscustomobject]@{
      person = $node.name
      expected_parent = $expectedParentName
      issue = 'not found in seed with this parent'
    }
    continue
  }

  $seedIds = @($seedMatch)
  if ($seedIds.Count -gt 1) {
    $parentMismatches += [pscustomobject]@{
      person = $node.name
      expected_parent = $expectedParentName
      issue = "ambiguous ($($seedIds.Count) seed matches)"
    }
    continue
  }

  $seedId = $seedIds[0]
  $actualParentName = if ($seedFatherOf.ContainsKey($seedId)) { $idToName[$seedFatherOf[$seedId]] } else { '' }
  if ($actualParentName -ne $expectedParentName) {
    $parentMismatches += [pscustomobject]@{
      person = $node.name
      expected_parent = $expectedParentName
      actual_parent = $actualParentName
      issue = 'wrong parent in seed'
    }
  }

  if ($idToBirthOrder.ContainsKey($seedId) -and $idToBirthOrder[$seedId] -ne $node.birth_order) {
    $orderMismatches += [pscustomobject]@{
      person = $node.name
      parent = $expectedParentName
      expected_order = $node.birth_order
      seed_order = $idToBirthOrder[$seedId]
    }
  }
}

Write-Host '--- Parent-child mismatches (CSV vs seed) ---'
Write-Host "Mismatches: $($parentMismatches.Count)"
$parentMismatches | Sort-Object person | Format-Table -AutoSize

Write-Host '--- Birth order mismatches ---'
Write-Host "Mismatches: $($orderMismatches.Count)"
$orderMismatches | Sort-Object parent, expected_order | Format-Table -AutoSize

# 5. Deep chains (likely parse errors - siblings chained horizontally)
Write-Host '--- Suspicious deep chains (5+ generations in one branch line) ---'
$deepChains = @()
foreach ($id in $idToName.Keys) {
  $chain = Get-Chain $seedFatherOf $id $idToName
  if ($chain.Count -ge 5 -and $chain[0] -ne 'CYCLE') {
    $deepChains += [pscustomobject]@{
      person = $idToName[$id]
      depth = $chain.Count
      chain = ($chain + $idToName[$id]) -join ' -> '
    }
  }
}
$deepChains | Sort-Object depth -Descending | Select-Object -First 20 | Format-Table -AutoSize

# 6. Uncle branch summary
Write-Host '--- Sons of SHEEKH YONIS (order & child counts) ---'
$patriarchKey = ($nodes.GetEnumerator() | Where-Object { $_.Value.name -eq 'SHEEKH YONIS' } | Select-Object -First 1).Key
$uncles = @($nodes.GetEnumerator() | Where-Object { $_.Value.parent -eq $patriarchKey } | Sort-Object { $_.Value.birth_order })
foreach ($u in $uncles) {
  $uncleName = $u.Value.name
  $kids = @($nodes.GetEnumerator() | Where-Object { $_.Value.parent -eq $u.Key } | Sort-Object { $_.Value.birth_order })
  $kidSummary = ($kids | ForEach-Object {
    $sub = @($nodes.GetEnumerator() | Where-Object { $_.Value.parent -eq $_.Key }).Count
    if ($sub -gt 0) { "$($_.Value.name)($sub)" } else { $_.Value.name }
  }) -join ', '
  Write-Host "  [$($u.Value.birth_order)] $uncleName : $($kids.Count) children -> $kidSummary"
}

# 7. Summary
$issues = $missingInSeed.Count + $extraInSeed.Count + $broken.Count + $parentMismatches.Count + $orderMismatches.Count
Write-Host ''
if ($issues -eq 0) {
  Write-Host 'RESULT: All checks passed.' -ForegroundColor Green
} else {
  Write-Host "RESULT: $issues issue(s) found - review above." -ForegroundColor Yellow
}
