$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_common.ps1')

# Install modules to a non-OneDrive location so cold imports don't wait on OneDrive to hydrate
# the files. The profile prepends this same path to $env:PSModulePath before importing them.
$moduleRoot = Join-Path $env:LOCALAPPDATA 'PowerShellModules'
[void](New-Item -ItemType Directory $moduleRoot -Force)
if (";$env:PSModulePath;" -notlike "*;$moduleRoot;*") {
    $env:PSModulePath = "$moduleRoot;$env:PSModulePath"
}

# PowerShell modules to install from the PowerShell Gallery
$modules = @(
    'Terminal-Icons'
    'PSReadLine'
    'PSFzf'
)

function Test-ModuleInstalled {
    param([string]$Name)
    return (Test-Path (Join-Path $moduleRoot $Name))
}

$results = [ordered]@{}

Write-Host ""
Write-Host "Installing PowerShell modules" -ForegroundColor Cyan
Write-Host "-----------------------------" -ForegroundColor Cyan

# Make sure the PowerShell Gallery can be used without interactive prompts
try { [void](Get-PackageProvider -Name NuGet -ForceBootstrap -ErrorAction Stop) } catch { }
try { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction Stop } catch { }

foreach ($name in $modules) {
    if (Test-ModuleInstalled -Name $name) {
        Write-Host ("  {0} already installed" -f $name.PadRight(20)) -ForegroundColor Yellow
        $results[$name] = 'AlreadyInstalled'
        continue
    }

    $ok = Invoke-JobWithSpinner -Label $name -Work {
        param($n, $dir)
        Save-Module -Name $n -Path $dir -Repository PSGallery -Force
    } -ArgumentList $name, $moduleRoot
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
