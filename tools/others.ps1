$ErrorActionPreference = 'Stop'
# winget/choco/pip report state through exit codes; keep non-zero exits from becoming
# terminating errors so the $LASTEXITCODE checks below work (default changed in PowerShell 7.4)
$PSNativeCommandUseErrorActionPreference = $false

. (Join-Path $PSScriptRoot '_common.ps1')

Write-Host ""
Write-Host "Installing other tools" -ForegroundColor Cyan
Write-Host "----------------------" -ForegroundColor Cyan

# Refresh PATH so a Python/Git install done earlier in this session (winget.ps1) is visible
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path', 'User')

# Resolve a real Python interpreter, skipping the Microsoft Store "App execution alias" stubs under
# WindowsApps. Those stubs print nothing and exit non-zero, which shows up as a blank 'failed'.
function Resolve-RealCommand([string]$name) {
    Get-Command $name -All -ErrorAction SilentlyContinue |
        Where-Object { $_.Source -and $_.Source -notlike '*\WindowsApps\*' } |
        Select-Object -First 1 -ExpandProperty Source
}
$python = Resolve-RealCommand 'python'
if (-not $python) { $python = Resolve-RealCommand 'py' }
if (-not $python) {
    Write-Host "  Python was not found. Install it first (tools/winget.ps1) and run this script again." -ForegroundColor Red
    return
}

# Prefer pip3 (as in the repo docs: 'pip3 install git+...'); fall back to '<python> -m pip'
$pip3 = Resolve-RealCommand 'pip3'
if ($pip3) { $pipExe = $pip3;   $pipArgs = @() }
else       { $pipExe = $python; $pipArgs = @('-m', 'pip') }

# Pokemon-Terminal is only distributed through pip (https://github.com/LazoCoder/Pokemon-Terminal)
$label = 'Pokemon-Terminal'

# Detect current state. try/catch guarantees a non-zero pip exit can never silently abort the
# script, even on a shell where $PSNativeCommandUseErrorActionPreference is not honored.
$installed = $false
try {
    & $pipExe @pipArgs show pokemon-terminal *> $null
    $installed = ($LASTEXITCODE -eq 0)
}
catch { $installed = $false }

if ($installed) {
    Write-Host ("  {0} already installed" -f $label.PadRight(20)) -ForegroundColor Yellow
}
else {
    # Exactly the command from the repo docs: pip3 install git+https://github.com/LazoCoder/Pokemon-Terminal.git
    $ok = Invoke-NativeWithSpinner -Label $label -FilePath $pipExe `
        -Arguments (@($pipArgs) + @('install', 'git+https://github.com/LazoCoder/Pokemon-Terminal.git'))
    if (-not $ok) { return }
}

# 'pokemon' lands in Python's Scripts folder. Depending on whether pip used --user this is the
# system or the per-user Scripts dir, so make both visible now and persist them for new shells.
$scriptDirs = @(
    (& $python -c "import sysconfig; print(sysconfig.get_path('scripts'))").Trim()
    (& $python -c "import sysconfig; print(sysconfig.get_path('scripts', 'nt_user'))").Trim()
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique

foreach ($dir in $scriptDirs) {
    if (";$env:Path;" -notlike "*;$dir;*") {
        $env:Path = "$dir;$env:Path"
        $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
        [System.Environment]::SetEnvironmentVariable('Path', "$userPath;$dir", 'User')
    }
}

# Once installed and reloaded, show Mew in the terminal
$pokemon = (Get-Command pokemon -ErrorAction SilentlyContinue).Source
if (-not $pokemon) {
    foreach ($dir in $scriptDirs) {
        $candidate = Join-Path $dir 'pokemon.exe'
        if (Test-Path $candidate) { $pokemon = $candidate; break }
    }
}
if ($pokemon) {
    Write-Host "  Running 'pokemon mew'..." -ForegroundColor Cyan
    & $pokemon mew
}
else {
    Write-Host "  'pokemon' command not found; open a new terminal and run 'pokemon mew'." -ForegroundColor Yellow
}

# Final verdict so it is always clear whether the package ended up installed (handy when debugging)
$installedNow = $false
try {
    & $pipExe @pipArgs show pokemon-terminal *> $null
    $installedNow = ($LASTEXITCODE -eq 0)
}
catch { $installedNow = $false }
if ($installedNow) {
    Write-Host "  Verified: pokemon-terminal is installed." -ForegroundColor Green
}
else {
    Write-Host "  Verified: pokemon-terminal is NOT installed. Run this manually to see the real error:" -ForegroundColor Red
    Write-Host "    pip3 install git+https://github.com/LazoCoder/Pokemon-Terminal.git" -ForegroundColor DarkGray
}

Write-Host ""
