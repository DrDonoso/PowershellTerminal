$ErrorActionPreference = 'Stop'
# choco reports state through exit codes; keep non-zero exits from becoming terminating
# errors so the $LASTEXITCODE checks below work (default changed in PowerShell 7.4)
$PSNativeCommandUseErrorActionPreference = $false

. (Join-Path $PSScriptRoot '_common.ps1')

# Friendly name => chocolatey package id
$packages = [ordered]@{
    'gawk' = 'gawk'
}

# Refresh PATH so a Chocolatey install done earlier in this session (winget.ps1) is visible
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path', 'User')

$chocoRoot = $env:ChocolateyInstall
if (-not $chocoRoot) { $chocoRoot = Join-Path $env:ProgramData 'chocolatey' }

$choco = (Get-Command choco -ErrorAction SilentlyContinue).Source
if (-not $choco) {
    $chocoExe = Join-Path $chocoRoot 'bin\choco.exe'
    if (Test-Path $chocoExe) { $choco = $chocoExe }
}
if (-not $choco) {
    Write-Host "Chocolatey (choco) was not found. Install it from https://chocolatey.org/install and run this script again." -ForegroundColor Red
    return
}

function Test-Installed {
    param([string]$Id)
    return (Test-Path (Join-Path $chocoRoot "lib\$Id"))
}

$results = [ordered]@{}

Write-Host ""
Write-Host "Installing tools with Chocolatey" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Cyan

foreach ($name in $packages.Keys) {
    $id = $packages[$name]

    if (Test-Installed -Id $id) {
        Write-Host ("  {0} already installed" -f $name.PadRight(20)) -ForegroundColor Yellow
        $results[$name] = 'AlreadyInstalled'
        continue
    }

    $ok = Invoke-NativeWithSpinner -Label $name -FilePath $choco `
        -Arguments @('install', $id, '-y', '--no-progress') -SuccessExitCodes @(0, 3010)
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
