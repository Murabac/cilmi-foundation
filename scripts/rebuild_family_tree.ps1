param(
  [string]$Source = "",
  [string]$Dest = "$PSScriptRoot\..\data\family_tree.csv"
)

$ErrorActionPreference = 'Stop'

if (-not $Source) {
  $candidates = @(
    "$env:USERPROFILE\Downloads\SHEEK YOONIS - FINAL(3) - ADEER.csv",
    "$env:USERPROFILE\Downloads\SHEEK YOONIS - FINAL(1) - ADEER(1).csv",
    "$env:USERPROFILE\Downloads\SHEEK YOONIS - FINAL(1) - ADEER.csv"
  )
  foreach ($path in $candidates) {
    if (Test-Path $path) {
      $Source = $path
      break
    }
  }
}

if (-not $Source -or -not (Test-Path $Source)) {
  throw @"
Family tree CSV not found.

Copy your export to Downloads as either:
  SHEEK YOONIS - FINAL(3) - ADEER.csv
  SHEEK YOONIS - FINAL(1) - ADEER(1).csv
  SHEEK YOONIS - FINAL(1) - ADEER.csv
"@
}

Write-Host "Using source: $Source"

$lines = Get-Content -Path $Source -Encoding UTF8
$out = foreach ($line in $lines) {
  if ($line -match '^SH\.\s*YONIS,') {
    $line -replace '^SH\.\s*YONIS,', 'SHEEKH YONIS,'
  }
  else {
    $line
  }
}

$out | Set-Content -Path $Dest -Encoding UTF8
Write-Host "Synced $($out.Count) lines to $Dest"

& "$PSScriptRoot\generate_seed.ps1" -CsvPath $Dest
& "$PSScriptRoot\validate_tree.ps1"

Write-Host ""
Write-Host "Next: run supabase/seed_family.sql in Supabase SQL Editor to refresh father_id links."
