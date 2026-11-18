# CILMI Foundation - commit, push, install release build on the connected phone,
# and build the Play Store bundle. Run from the project folder:
#   powershell -ExecutionPolicy Bypass -File .\scripts\release.ps1
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

function Step($msg) { Write-Host "`n=== $msg ===" -ForegroundColor Cyan }
function Check($what) {
  if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: $what" -ForegroundColor Red; exit 1 }
}

$version = (Select-String -Path pubspec.yaml -Pattern '^version:\s*(.+)$').Matches[0].Groups[1].Value
Write-Host "Version: $version" -ForegroundColor Yellow

Step "1/6 Commit"
git add -A; Check "git add"
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
  git commit -m "Release ${version}: fix container colours, privacy policy monthly status, release script."
  Check "git commit"
} else { Write-Host "Nothing new to commit." }

Step "2/6 Push"
git push; Check "git push"

Step "3/6 Dependencies + analyze"
flutter pub get; Check "flutter pub get"
flutter analyze --no-fatal-infos --no-fatal-warnings; Check "flutter analyze (errors)"

Step "4/6 Build release APK"
flutter build apk --release --dart-define-from-file=env.json; Check "build apk"

Step "5/6 Install on phone (replaces the debug app; you may need to log in again)"
flutter devices
flutter install --release; Check "flutter install"

Step "6/6 Build Play Store bundle (.aab)"
flutter build appbundle --release --dart-define-from-file=env.json; Check "build appbundle"

$aab = Resolve-Path "build\app\outputs\bundle\release\app-release.aab"
Write-Host "`nDONE. Upload this file to Play Console:" -ForegroundColor Green
Write-Host $aab -ForegroundColor Green
explorer.exe /select,"$aab"
