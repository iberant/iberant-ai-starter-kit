# Link CLAUDE.md -> AGENTS.md on Windows.
# Requires Developer Mode enabled (see setup-windows-dev.ps1). Run from the repository root.
$ErrorActionPreference = "Stop"

if (-not (Test-Path "AGENTS.md")) {
    Write-Host "AGENTS.md not found. Run /init in Claude (it creates CLAUDE.md), then rename it:"
    Write-Host "  Rename-Item CLAUDE.md AGENTS.md"
    exit 1
}

if (Test-Path "CLAUDE.md") { Remove-Item "CLAUDE.md" }
New-Item -ItemType SymbolicLink -Path "CLAUDE.md" -Target "AGENTS.md" | Out-Null
Write-Host "Linked CLAUDE.md -> AGENTS.md"
