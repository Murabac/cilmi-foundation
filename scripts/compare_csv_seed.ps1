param(
  [string]$CsvPath = "$PSScriptRoot\..\data\family_tree.csv"
)

$ErrorActionPreference = 'Stop'
$maxCol = 14

function Clean([string]$s) {
  if ([string]::IsNullOrWhiteSpace($s)) { return "" }
  return ($s.Trim() -replace "\s+", " ")
}

function ParseCells([string]$line) {
  $raw = $line -split ',', ($maxCol + 1)
  $cells = @()
  for ($i = 0; $i -le $maxCol; $i++) {
    if ($i -lt $raw.Count) { $cells += $raw[$i] } else { $cells += "" }
  }
  return $cells
}

$rawNames = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$lines = Get-Content -Path $CsvPath -Encoding UTF8
foreach ($line in $lines[1..($lines.Count - 1)]) {
  if ([string]::IsNullOrWhiteSpace($line)) { continue }
  foreach ($cell in (ParseCells $line)) {
    $val = Clean $cell
    if ($val -and $val -notin @('GRANDPARENT', 'UNCLE', 'CHILD', 'GRANDCHILD')) {
      [void]$rawNames.Add($val)
    }
  }
}

$seed = Get-Content "$PSScriptRoot\..\supabase\seed_family.sql" -Raw
$seedNames = [regex]::Matches($seed, "VALUES \('[^']+', '([^']+)'") |
  ForEach-Object { $_.Groups[1].Value }

Write-Host "Raw CSV unique names: $($rawNames.Count)"
Write-Host "Seed profiles: $($seedNames.Count)"

$missing = @($rawNames | Where-Object { $_ -notin $seedNames })
$extra = @($seedNames | Where-Object { $_ -notin $rawNames })

Write-Host "In CSV but not seed: $($missing.Count)"
if ($missing.Count -gt 0) { $missing | Sort-Object | ForEach-Object { Write-Host "  $_" } }
Write-Host "In seed but not CSV (dup keys ok): $($extra.Count)"
