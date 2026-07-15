param(
  [string]$CsvPath = "$PSScriptRoot\..\data\family_tree.csv"
)

$ErrorActionPreference = 'Stop'
$OutPath = "$env:TEMP\rsy_debug.sql"
& "$PSScriptRoot\generate_seed.ps1" -CsvPath $CsvPath -OutPath $OutPath | Out-Null

$seed = Get-Content $OutPath -Raw
$inserts = [regex]::Matches($seed, "VALUES \('([^']+)', '([^']+)'")
$updates = [regex]::Matches($seed, "UPDATE reer_sh_yoonis.profiles SET father_id = '([^']+)' WHERE id = '([^']+)'")
$idToName = @{}; foreach ($m in $inserts) { $idToName[$m.Groups[1].Value] = $m.Groups[2].Value }
$fatherOf = @{}; foreach ($m in $updates) { $fatherOf[$m.Groups[2].Value] = $m.Groups[1].Value }

function Show-Chain([string]$startName) {
  $cur = ($idToName.GetEnumerator() | Where-Object { $_.Value -eq $startName } | Select-Object -First 1).Key
  if (-not $cur) { Write-Host "$startName : NOT FOUND"; return }
  $parts = @($startName)
  for ($i = 0; $i -lt 8; $i++) {
    if (-not $fatherOf.ContainsKey($cur)) { break }
    $cur = $fatherOf[$cur]
    $parts += $idToName[$cur]
  }
  [array]::Reverse($parts)
  Write-Host ($parts -join ' -> ')
}

Write-Host "Total profiles: $($inserts.Count)"
Write-Host ""
Write-Host 'CABDIQADIR branch chain samples:'
Show-Chain 'ANAS'
Show-Chain 'YOONIS'
Show-Chain 'SAKARIYE'
Write-Host ''
Write-Host 'MIRE branch:'
Show-Chain 'ASMA'
Show-Chain 'MUKHTAAR'
Show-Chain 'FILSAN'
Write-Host ''
Write-Host 'CABDILAAHI branch:'
Show-Chain 'NADIIRA'
Show-Chain 'C/QANI'
