$ErrorActionPreference = 'Stop'

$packages = @(
    'Git.Git',
    'Telegram.TelegramDesktop',
    'Bitwarden.Bitwarden'
)

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host -BackgroundColor Red -ForegroundColor Black "winget not found. Install 'App Installer' from the Microsoft Store and retry."
    return
}

foreach ($id in $packages) {
    Write-Host -BackgroundColor Blue -ForegroundColor Black "Installing $id..." -NoNewline
    winget install --id $id --exact --source winget --accept-source-agreements --accept-package-agreements --silent
    if ($LASTEXITCODE -eq 0) {
        Write-Host -BackgroundColor Green -ForegroundColor Black "   Installed"
    } else {
        Write-Host -BackgroundColor Yellow -ForegroundColor Black "   Already installed or skipped (exit $LASTEXITCODE)"
    }
}
