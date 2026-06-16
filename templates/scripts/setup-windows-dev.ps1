# One-time Windows setup so git symlinks (CLAUDE.md -> AGENTS.md) work.
# Run in an elevated (Administrator) PowerShell.
$ErrorActionPreference = "Stop"

# 1. Enable Developer Mode (allows creating symlinks without admin per-call).
$key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
if (-not (Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
Set-ItemProperty -Path $key -Name "AllowDevelopmentWithoutDevLicense" -Value 1
Write-Host "Developer Mode enabled."

# Or open the Settings UI manually:  start ms-settings:developers

# 2. Tell git to materialize symlinks on checkout.
git config --global core.symlinks true
Write-Host "git core.symlinks = true (global)."

Write-Host "Done. Re-clone the repo (or 'git checkout -- .') so symlinks are recreated."
