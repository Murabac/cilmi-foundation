param(
  [string]$CsvPath = "$PSScriptRoot\..\data\family_tree.csv"
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\generate_seed.ps1" -CsvPath $CsvPath -OutPath "$env:TEMP\rsy_seed_test.sql" | Out-Null

# Re-run parser logic inline by dot-sourcing won't work cleanly; invoke generate and parse output
& "$PSScriptRoot\generate_seed.ps1" -CsvPath $CsvPath -OutPath "$env:TEMP\rsy_seed_test.sql" | Out-Null

$seed = Get-Content "$env:TEMP\rsy_seed_test.sql" -Raw
$inserts = [regex]::Matches($seed, "VALUES \('([^']+)', '([^']+)'")
$updates = [regex]::Matches($seed, "UPDATE reer_sh_yoonis.profiles SET father_id = '([^']+)' WHERE id = '([^']+)'")

$idToName = @{}
foreach ($m in $inserts) {
  $idToName[$m.Groups[1].Value] = $m.Groups[2].Value
}

$fatherOf = @{}
foreach ($m in $updates) {
  $fatherOf[$m.Groups[2].Value] = $m.Groups[1].Value
}

$roots = @()
$orphans = @()
foreach ($id in $idToName.Keys) {
  if (-not $fatherOf.ContainsKey($id)) {
    $name = $idToName[$id]
    if ($name -notmatch 'SHEEKH YONIS') {
      $orphans += [pscustomobject]@{ name = $name; id = $id }
    }
    else {
      $roots += $name
    }
  }
}

Write-Host "Total profiles: $($idToName.Count)"
Write-Host "Patriarch roots: $($roots -join ', ')"
Write-Host "Profiles without father_id (excluding patriarch): $($orphans.Count)"
if ($orphans.Count -gt 0) {
  Write-Host '--- Orphans (disconnected from tree) ---'
  $orphans | Sort-Object name | Format-Table -AutoSize
}

# Duplicate names under different parents
$nameGroups = $idToName.GetEnumerator() | Group-Object Value
$dups = $nameGroups | Where-Object { $_.Count -gt 1 }
Write-Host "Duplicate full names: $($dups.Count)"
foreach ($g in ($dups | Sort-Object Name)) {
  Write-Host "  $($g.Name) x$($g.Count)"
}
