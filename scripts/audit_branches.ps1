$ErrorActionPreference = 'Stop'
$seed = Get-Content "$PSScriptRoot\..\supabase\seed_family.sql" -Raw

$inserts = [regex]::Matches($seed, "VALUES \('([^']+)', '((?:[^']|'')*)'")
$idToName = @{}
$idToOrder = @{}
foreach ($m in $inserts) {
  $id = $m.Groups[1].Value
  $name = $m.Groups[2].Value -replace "''", "'"
  $idToName[$id] = $name
}

$orderMatches = [regex]::Matches($seed, "VALUES \('([^']+)', '((?:[^']|'')*)', NULL, 'family_member', 'adult', 2, (\d+)\)")
foreach ($m in $orderMatches) {
  $idToOrder[$m.Groups[1].Value] = [int]$m.Groups[3].Value
}

$updates = [regex]::Matches($seed, "UPDATE reer_sh_yoonis.profiles SET father_id = '([^']+)' WHERE id = '([^']+)'")
$fatherOf = @{}
$childrenOf = @{}
foreach ($m in $updates) {
  $child = $m.Groups[2].Value
  $parent = $m.Groups[1].Value
  $fatherOf[$child] = $parent
  if (-not $childrenOf.ContainsKey($parent)) { $childrenOf[$parent] = @() }
  $childrenOf[$parent] += $child
}

function Get-Chain([string]$id) {
  $parts = @($idToName[$id])
  $cur = $id
  $seen = @{}
  while ($fatherOf.ContainsKey($cur)) {
    if ($seen.ContainsKey($cur)) { return @('CYCLE') + $parts; break }
    $seen[$cur] = $true
    $cur = $fatherOf[$cur]
    $parts = @($idToName[$cur]) + $parts
  }
  return $parts
}

Write-Host "Profiles in seed: $($idToName.Count)"
Write-Host ''

# CABDIQADIR audit
$cabId = ($idToName.GetEnumerator() | Where-Object { $_.Value -eq 'CABDIQADIR' } | Select-Object -First 1).Key
Write-Host '=== CABDIQADIR branch ==='
$cabKids = @($childrenOf[$cabId] | ForEach-Object { [pscustomobject]@{ id = $_; name = $idToName[$_]; order = $idToOrder[$_] } } | Sort-Object order)
foreach ($k in $cabKids) {
  $childIds = @($childrenOf[$k.id] | Where-Object { $_ })
  $sub = @($childIds | ForEach-Object { $idToName[$_] }) -join ', '
  $subCount = $childIds.Count
  Write-Host "  [$($k.order)] $($k.name) -> $subCount children: $sub"
}

Write-Host ''
Write-Host '=== Potential data flags ==='

# Branch header row: FADXIYA + XAMDA on same row as new uncle
Write-Host 'XAMDA under CABDIQADIR (check if should be sibling of FADXIYA):'
foreach ($id in $idToName.Keys) {
  $chain = Get-Chain $id
  if ($idToName[$id] -eq 'XAMDA' -and ($chain -join ' -> ') -like '*CABDIQADIR*') {
    Write-Host "  $($chain -join ' -> ')"
  }
}

Write-Host 'CALI child (user said only CISMAAN/NUURA have kids):'
foreach ($id in $idToName.Keys) {
  if ($idToName[$id] -eq 'CALI' -and (Get-Chain $id)[-2] -eq 'CABDIQADIR') {
    $calId = $id
    $calKids = @($childrenOf[$calId] | ForEach-Object { $idToName[$_] })
    Write-Host "  CALI children: $($calKids -join ', ')"
  }
}

# Deep chains
Write-Host ''
Write-Host 'Deep chains (depth >= 5):'
foreach ($id in $idToName.Keys) {
  $chain = Get-Chain $id
  if ($chain.Count -ge 5 -and $chain[0] -ne 'CYCLE') {
    Write-Host "  depth $($chain.Count): $($chain -join ' -> ')"
  }
}

# MIRE branch (was problematic before)
Write-Host ''
Write-Host '=== MIRE branch (HODAN children) ==='
$mireId = ($idToName.GetEnumerator() | Where-Object { $_.Value -eq 'MIRE' } | Select-Object -First 1).Key
$cRahimId = ($childrenOf[$mireId] | Where-Object { $idToName[$_] -eq 'C/RAHIM' } | Select-Object -First 1)
if ($cRahimId) {
  $crKids = @($childrenOf[$cRahimId] | ForEach-Object { [pscustomobject]@{ name = $idToName[$_]; order = $idToOrder[$_] } } | Sort-Object order)
  Write-Host "  C/RAHIM children ($($crKids.Count)): $(($crKids.name) -join ', ')"
}

# Duplicate name same parent
Write-Host ''
Write-Host 'Duplicate names under same parent:'
$byParentName = @{}
foreach ($id in $idToName.Keys) {
  if (-not $fatherOf.ContainsKey($id)) { continue }
  $p = $idToName[$fatherOf[$id]]
  $k = "$p|$($idToName[$id])"
  if (-not $byParentName.ContainsKey($k)) { $byParentName[$k] = 0 }
  $byParentName[$k]++
}
$byParentName.GetEnumerator() | Where-Object { $_.Value -gt 1 } | ForEach-Object { Write-Host "  $($_.Key) x$($_.Value)" }
