param(
  [string]$OutPath = "$PSScriptRoot\..\supabase\migrations_017_018.sql"
)

$files = @(
  '017_security_and_claim_requests.sql',
  '018_super_admin_claim_approval.sql'
)

$header = @"
-- Run this if you ALREADY have migrations 001-016 (do NOT run all_migrations.sql).
-- If you see "type user_role already exists", your DB is not empty — use this file instead.

"@

$parts = New-Object System.Collections.Generic.List[string]
$parts.Add($header.Trim())

foreach ($name in $files) {
  $path = Join-Path "$PSScriptRoot\..\supabase\migrations" $name
  $parts.Add("")
  $parts.Add("-- $name")
  $parts.Add((Get-Content -Path $path -Raw -Encoding UTF8).Trim())
}

$parts -join "`n" | Set-Content -Path $OutPath -Encoding UTF8
Write-Host "Wrote $OutPath"
