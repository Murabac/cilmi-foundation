$ErrorActionPreference = 'Stop'
$seed = Get-Content "$PSScriptRoot\..\supabase\seed_family.sql" -Raw
$inserts = [regex]::Matches($seed, "VALUES \('([^']+)', '((?:[^']|'')*)'")
$idToName = @{}
foreach ($m in $inserts) { $idToName[$m.Groups[1].Value] = ($m.Groups[2].Value -replace "''", "'") }
$updates = [regex]::Matches($seed, "UPDATE reer_sh_yoonis.profiles SET father_id = '([^']+)' WHERE id = '([^']+)'")
$fatherOf = @{}; $childrenOf = @{}
foreach ($m in $updates) {
  $fatherOf[$m.Groups[2].Value] = $m.Groups[1].Value
  if (-not $childrenOf.ContainsKey($m.Groups[1].Value)) { $childrenOf[$m.Groups[1].Value] = @() }
  $childrenOf[$m.Groups[1].Value] += $m.Groups[2].Value
}
function Chain($id) {
  $p = @($idToName[$id]); $c = $id; $seen = @{}
  while ($fatherOf.ContainsKey($c)) {
    if ($seen[$c]) { break }; $seen[$c] = $true
    $c = $fatherOf[$c]; $p = @($idToName[$c]) + $p
  }
  return $p -join ' -> '
}
$mireId = ($idToName.GetEnumerator() | Where-Object { $_.Value -eq 'MIRE' } | Select-Object -First 1).Key
$orderMatches = [regex]::Matches($seed, "VALUES \('([^']+)', '((?:[^']|'')*)', NULL, 'family_member', 'adult', 2, (\d+)\)")
$order = @{}
foreach ($m in $orderMatches) { $order[$m.Groups[1].Value] = [int]$m.Groups[3].Value }

Write-Host '=== MIRE branch ==='
$mireKids = @($childrenOf[$mireId] | Where-Object { $_ } | Sort-Object { $order[$_] })
foreach ($cid in $mireKids) {
  $childIds = @($childrenOf[$cid] | Where-Object { $_ } | Sort-Object { $order[$_] })
  $sub = @($childIds | ForEach-Object { $idToName[$_] })
  Write-Host "[$($order[$cid])] $($idToName[$cid]) ($($sub.Count) kids): $($sub -join ', ')"
}
