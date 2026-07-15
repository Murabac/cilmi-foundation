$ErrorActionPreference = 'Stop'
$seed = Get-Content "$PSScriptRoot\..\supabase\seed_family.sql" -Raw
$inserts = [regex]::Matches($seed, "VALUES \('([^']+)', '([^']+)'")
$updates = [regex]::Matches($seed, "UPDATE reer_sh_yoonis.profiles SET father_id = '([^']+)' WHERE id = '([^']+)'")

$idToName = @{}
foreach ($m in $inserts) { $idToName[$m.Groups[1].Value] = $m.Groups[2].Value }

$fatherOf = @{}
foreach ($m in $updates) { $fatherOf[$m.Groups[2].Value] = $m.Groups[1].Value }

$rootId = ($idToName.GetEnumerator() | Where-Object { $_.Value -eq 'SHEEKH YONIS' } | Select-Object -First 1).Key
if (-not $rootId) { throw 'Patriarch not found in seed.' }

$broken = @()
foreach ($id in $idToName.Keys) {
  if ($id -eq $rootId) { continue }
  $cur = $id
  $seen = @{}
  $ok = $false
  while ($fatherOf.ContainsKey($cur)) {
    if ($seen.ContainsKey($cur)) { break }
    $seen[$cur] = $true
    $cur = $fatherOf[$cur]
    if ($cur -eq $rootId) { $ok = $true; break }
  }
  if (-not $ok) {
    $broken += [pscustomobject]@{
      name = $idToName[$id]
      id = $id
      father = if ($fatherOf.ContainsKey($id)) { $idToName[$fatherOf[$id]] } else { '(none)' }
    }
  }
}

Write-Host "Profiles: $($idToName.Count)"
Write-Host "Patriarch id: $rootId"
Write-Host "Not reaching patriarch: $($broken.Count)"
$broken | Sort-Object name | Format-Table -AutoSize

# Wrong parent guesses: same name appears under multiple fathers in CSV logic
Write-Host ''
Write-Host 'Duplicate names (expected for common names):'
$idToName.Values | Group-Object | Where-Object { $_.Count -gt 1 } | Sort-Object Count -Descending | Select-Object -First 15 | Format-Table Name, Count
