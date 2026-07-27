# Captures this machine's Windows Terminal settings.json back into the repo so the change can be
# reviewed and committed. Run it after tweaking Terminal from the UI:
#   pwsh -File terminal\export-settings.ps1
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_terminal.ps1')

$source = Get-WindowsTerminalSettingsPath
if (-not $source -or -not (Test-Path $source)) {
    Write-Host "Windows Terminal settings.json was not found on this machine." -ForegroundColor Red
    return
}

$dest = Join-Path $PSScriptRoot 'settings.json'
Copy-Item $source $dest -Force
Write-Host "Exported Windows Terminal settings:" -ForegroundColor Green
Write-Host "  from $source"
Write-Host "  to   $dest"
Write-Host "Review the diff and commit it to sync the change." -ForegroundColor Cyan
