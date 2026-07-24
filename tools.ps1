$ErrorActionPreference = 'Stop'

# Friendly name => winget package id
$packages = [ordered]@{
    'Git'                = 'Git.Git'
    'Telegram'           = 'Telegram.TelegramDesktop'
    'Bitwarden'          = 'Bitwarden.Bitwarden'
    'Visual Studio Code' = 'Microsoft.VisualStudioCode'
    'Docker Desktop'     = 'Docker.DockerDesktop'
    'Brave Browser'      = 'Brave.Brave'
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget was not found. Install 'App Installer' from the Microsoft Store and run this script again." -ForegroundColor Red
    return
}

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
    Write-Host ("  {0,-20} " -f $name) -NoNewline

    if (Test-Installed -Id $id) {
        Write-Host "already installed" -ForegroundColor Yellow
        $results[$name] = 'AlreadyInstalled'
        continue
    }

    winget install --id $id --exact --source winget --accept-source-agreements --accept-package-agreements --silent *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "installed" -ForegroundColor Green
        $results[$name] = 'Installed'
    }
    else {
        Write-Host ("failed (exit {0})" -f $LASTEXITCODE) -ForegroundColor Red
        $results[$name] = "Failed:$LASTEXITCODE"
    }
}

$installed = @($results.Keys | Where-Object { $results[$_] -eq 'Installed' })
$already   = @($results.Keys | Where-Object { $results[$_] -eq 'AlreadyInstalled' })
$failed    = @($results.Keys | Where-Object { $results[$_] -like 'Failed:*' })

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
    foreach ($n in $failed) {
        $code = $results[$n] -replace '^Failed:', ''
        Write-Host "  x $n (exit $code)" -ForegroundColor Red
    }
}
Write-Host ""
