$ErrorActionPreference = 'Stop'
# winget reports state through exit codes; keep non-zero exits from becoming terminating
# errors so the $LASTEXITCODE checks below work (default changed in PowerShell 7.4)
$PSNativeCommandUseErrorActionPreference = $false

. (Join-Path $PSScriptRoot '_common.ps1')

# Friendly name => winget package id
$packages = [ordered]@{
    'Git'                = 'Git.Git'
    'Telegram'           = 'Telegram.TelegramDesktop'
    'Bitwarden'          = 'Bitwarden.Bitwarden'
    'Visual Studio Code' = 'Microsoft.VisualStudioCode'
    'Docker Desktop'     = 'Docker.DockerDesktop'
    'Brave Browser'      = 'Brave.Brave'
    'GitHub Copilot CLI' = 'GitHub.Copilot'
    'GitHub Copilot App' = 'GitHub.CopilotApp'
    'Node.js (LTS)'      = 'OpenJS.NodeJS.LTS'
    'Python 3.13'        = 'Python.Python.3.13'
    'GitHub CLI'         = 'GitHub.cli'
    'Azure CLI'          = 'Microsoft.AzureCLI'
    'GnuPG'              = 'GnuPG.GnuPG'
    'WSL'                = 'Microsoft.WSL'
    'Chocolatey'         = 'Chocolatey.Chocolatey'
    'fzf'                = 'junegunn.fzf'
    'Oh My Posh'         = 'JanDeDobbeleer.OhMyPosh'
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget was not found. Install 'App Installer' from the Microsoft Store and run this script again." -ForegroundColor Red
    return
}
$winget = (Get-Command winget -ErrorAction SilentlyContinue).Source

function Test-Installed {
    param([string]$Id)
    winget list --id $Id --exact --accept-source-agreements *> $null
    return ($LASTEXITCODE -eq 0)
}

$results = [ordered]@{}

Write-Host ""
Write-Host "Installing tools with winget" -ForegroundColor Cyan
Write-Host "----------------------------" -ForegroundColor Cyan

foreach ($name in $packages.Keys) {
    $id = $packages[$name]

    if (Test-Installed -Id $id) {
        Write-Host ("  {0} already installed" -f $name.PadRight(20)) -ForegroundColor Yellow
        $results[$name] = 'AlreadyInstalled'
        continue
    }

    $ok = Invoke-NativeWithSpinner -Label $name -FilePath $winget -Arguments @(
        'install', '--id', $id, '--exact', '--source', 'winget',
        '--accept-source-agreements', '--accept-package-agreements', '--silent'
    )
    $results[$name] = if ($ok) { 'Installed' } else { 'Failed' }
}

$installed = @($results.Keys | Where-Object { $results[$_] -eq 'Installed' })
$already   = @($results.Keys | Where-Object { $results[$_] -eq 'AlreadyInstalled' })
$failed    = @($results.Keys | Where-Object { $results[$_] -eq 'Failed' })

Write-Host ""
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "-------" -ForegroundColor Cyan

if ($installed.Count) {
    Write-Host ("Installed ({0}):" -f $installed.Count) -ForegroundColor Green
    foreach ($n in $installed) { Write-Host "  + $n" -ForegroundColor Green }
}
if ($already.Count) {
    Write-Host ("Already installed ({0}):" -f $already.Count) -ForegroundColor Yellow
    foreach ($n in $already) { Write-Host "  = $n" -ForegroundColor Yellow }
}
if ($failed.Count) {
    Write-Host ("Failed ({0}):" -f $failed.Count) -ForegroundColor Red
    foreach ($n in $failed) { Write-Host "  x $n" -ForegroundColor Red }
}
Write-Host ""
