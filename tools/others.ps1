$ErrorActionPreference = 'Stop'
# winget/choco/pip report state through exit codes; keep non-zero exits from becoming
# terminating errors so the $LASTEXITCODE checks below work (default changed in PowerShell 7.4)
$PSNativeCommandUseErrorActionPreference = $false

Write-Host ""
Write-Host "Installing other tools" -ForegroundColor Cyan
Write-Host "----------------------" -ForegroundColor Cyan

# Refresh PATH so a Python/Git install done earlier in this session (winget.ps1) is visible
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path', 'User')

# Resolve a Python interpreter (installed via winget.ps1)
$python = (Get-Command python -ErrorAction SilentlyContinue).Source
if (-not $python) { $python = (Get-Command py -ErrorAction SilentlyContinue).Source }
if (-not $python) {
    Write-Host "  Python was not found. Install it first (tools/winget.ps1) and run this script again." -ForegroundColor Red
    return
}

# Prefer pip3 (as in the repo docs); fall back to 'python -m pip' when it is not on PATH yet
$pip3 = (Get-Command pip3 -ErrorAction SilentlyContinue).Source
if ($pip3) { $pipExe = $pip3;   $pipArgs = @() }
else       { $pipExe = $python; $pipArgs = @('-m', 'pip') }

# Pokemon-Terminal is only distributed through pip (https://github.com/LazoCoder/Pokemon-Terminal)
Write-Host "  Pokemon-Terminal" -ForegroundColor White

# Skip the reinstall when it is already present (installing from a git URL re-clones on every run)
& $pipExe @pipArgs show pokemon-terminal *> $null
if ($LASTEXITCODE -eq 0) {
    Write-Host "    already installed" -ForegroundColor Yellow
}
else {
    # Exactly the command from the repo docs: pip3 install git+https://github.com/LazoCoder/Pokemon-Terminal.git
    $log = & $pipExe @pipArgs install git+https://github.com/LazoCoder/Pokemon-Terminal.git 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    installed" -ForegroundColor Green
    }
    else {
        Write-Host ("    failed (exit {0}):" -f $LASTEXITCODE) -ForegroundColor Red
        $log | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
        return
    }
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

Write-Host ""
