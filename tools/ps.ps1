$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_common.ps1')

# Install modules to a non-OneDrive location so cold imports don't wait on OneDrive to hydrate
# the files. The profile prepends this same path to $env:PSModulePath before importing them.
# Modules are fetched as raw .nupkg packages (see below) to avoid the PowerShellGet/NuGet
# provider, which is old or missing on Windows PowerShell 5.1 and hangs Save-Module.
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

foreach ($name in $modules) {
    if (Test-ModuleInstalled -Name $name) {
        Write-Host ("  {0} already installed" -f $name.PadRight(20)) -ForegroundColor Yellow
        $results[$name] = 'AlreadyInstalled'
        continue
    }

    $ok = Invoke-JobWithSpinner -Label $name -Work {
        param($n, $dir)
        $ErrorActionPreference = 'Stop'
        $ProgressPreference = 'SilentlyContinue'
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        # A .nupkg is just a zip, so downloading and unzipping it needs no PowerShellGet/NuGet
        # provider. On Windows PowerShell 5.1 that provider is old/missing and makes Save-Module
        # hang on an interactive bootstrap prompt inside the job, so we avoid it entirely.
        $tmp = Join-Path $env:TEMP ("psmod-" + [guid]::NewGuid())
        [void](New-Item -ItemType Directory $tmp -Force)
        try {
            $zip = Join-Path $tmp "$n.zip"
            Invoke-WebRequest -Uri "https://www.powershellgallery.com/api/v2/package/$n" -OutFile $zip -UseBasicParsing
            $target = Join-Path $dir $n
            if (Test-Path $target) { Remove-Item $target -Recurse -Force }
            Expand-Archive -Path $zip -DestinationPath $target -Force
            # Drop the NuGet packaging cruft so the module folder only holds the module files.
            foreach ($junk in '_rels', 'package', '[Content_Types].xml') {
                $p = Join-Path $target $junk
                if (Test-Path -LiteralPath $p) { Remove-Item -LiteralPath $p -Recurse -Force }
            }
            Get-ChildItem $target -Filter '*.nuspec' | Remove-Item -Force
        }
        finally {
            Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
        }
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
