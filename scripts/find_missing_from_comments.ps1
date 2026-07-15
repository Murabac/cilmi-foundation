$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$xlsx = "$env:USERPROFILE\Downloads\SHEEK YOONIS - FINAL(1).xlsx"
$tmp = Join-Path $env:TEMP 'rsy_comments'
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
New-Item -ItemType Directory -Path $tmp | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($xlsx, $tmp)

[xml]$comments = Get-Content (Join-Path $tmp 'xl\comments1.xml') -Raw
$commentNames = @()
foreach ($c in $comments.commentList.comment) {
  $t = $c.text.t.InnerText
  if ($t) { $commentNames += ($t -replace '\s+', ' ').Trim() }
}

$seed = Get-Content "$PSScriptRoot\..\supabase\seed_family.sql" -Raw
$inserts = [regex]::Matches($seed, "VALUES \('([^']+)', '([^']+)'")
$seedNames = @{}
foreach ($m in $inserts) { $seedNames[$m.Groups[2].Value.ToUpper()] = $true }

Write-Host "Comment-only names in xlsx (may be missing from seed):"
foreach ($n in ($commentNames | Sort-Object -Unique)) {
  if (-not $seedNames.ContainsKey($n.ToUpper())) {
    Write-Host "  MISSING: $n"
  }
}

Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
