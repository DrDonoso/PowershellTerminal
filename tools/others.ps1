$ErrorActionPreference = 'Stop'

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

# Pokemon-Terminal is only distributed through pip
Write-Host ("  {0,-20} " -f 'Pokemon-Terminal') -NoNewline
& $pipExe @pipArgs show pokemon-terminal *> $null
if ($LASTEXITCODE -eq 0) {
    Write-Host "already installed" -ForegroundColor Yellow
}
else {
    & $pipExe @pipArgs install --user git+https://github.com/LazoCoder/Pokemon-Terminal.git *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "installed" -ForegroundColor Green
    }
    else {
        Write-Host ("failed (exit {0})" -f $LASTEXITCODE) -ForegroundColor Red
        return
    }
}

# Make the per-user Scripts folder (where 'pokemon' lands) available now and in future sessions
$scriptsDir = (& $python -c "import sysconfig; print(sysconfig.get_path('scripts', 'nt_user'))").Trim()
if ($scriptsDir -and (Test-Path $scriptsDir)) {
    if (";$env:Path;" -notlike "*;$scriptsDir;*") { $env:Path = "$scriptsDir;$env:Path" }
    $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    if (";$userPath;" -notlike "*;$scriptsDir;*") {
        [System.Environment]::SetEnvironmentVariable('Path', "$userPath;$scriptsDir", 'User')
    }
}

# Once installed and reloaded, show Mew in the terminal
$pokemon = (Get-Command pokemon -ErrorAction SilentlyContinue).Source
if (-not $pokemon -and $scriptsDir) {
    $candidate = Join-Path $scriptsDir 'pokemon.exe'
    if (Test-Path $candidate) { $pokemon = $candidate }
}
if ($pokemon) {
    Write-Host "  Running 'pokemon mew'..." -ForegroundColor Cyan
    & $pokemon mew
}
else {
    Write-Host "  'pokemon' command not found; open a new terminal and run 'pokemon mew'." -ForegroundColor Yellow
}

Write-Host ""
