$ErrorActionPreference = 'Stop'

# PowerShell modules to install from the PowerShell Gallery
$modules = @(
    'Terminal-Icons'
    'PSReadLine'
    'PSFzf'
)

function Test-ModuleInstalled {
    param([string]$Name)
    return [bool](Get-Module -ListAvailable -Name $Name)
}

$results = [ordered]@{}

Write-Host ""
Write-Host "Installing PowerShell modules" -ForegroundColor Cyan
Write-Host "-----------------------------" -ForegroundColor Cyan

# Make sure the PowerShell Gallery can be used without interactive prompts
try { [void](Get-PackageProvider -Name NuGet -ForceBootstrap -ErrorAction Stop) } catch { }
try { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction Stop } catch { }

foreach ($name in $modules) {
    Write-Host ("  {0,-20} " -f $name) -NoNewline

    if (Test-ModuleInstalled -Name $name) {
        Write-Host "already installed" -ForegroundColor Yellow
        $results[$name] = 'AlreadyInstalled'
        continue
    }

    try {
        Install-Module -Name $name -Scope CurrentUser -Repository PSGallery -Force -AllowClobber
        Write-Host "installed" -ForegroundColor Green
        $results[$name] = 'Installed'
    }
    catch {
        Write-Host "failed" -ForegroundColor Red
        $results[$name] = "Failed:$($_.Exception.Message)"
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
        $msg = $results[$n] -replace '^Failed:', ''
        Write-Host "  x $n ($msg)" -ForegroundColor Red
    }
}
Write-Host ""
