param(
  [string]$Source = "$env:USERPROFILE\Downloads\SHEEK YOONIS - FINAL(3) - ADEER.csv",
  [string]$Dest = "$PSScriptRoot\..\data\family_tree.csv"
)

if (-not (Test-Path $Source)) {
  throw "Source CSV not found: $Source"
}

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
