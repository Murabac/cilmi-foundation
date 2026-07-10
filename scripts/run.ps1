# Run the app using credentials from env.json
$envFile = Join-Path $PSScriptRoot "..\env.json"
if (-not (Test-Path $envFile)) {
  Write-Error "env.json not found. Copy env.json.example to env.json and fill in your Supabase values."
  exit 1
}

Set-Location (Join-Path $PSScriptRoot "..")
flutter run --dart-define-from-file=env.json @args
