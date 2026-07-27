$documentsPath = [Environment]::GetFolderPath('MyDocuments')
$profileDir = Join-Path $documentsPath "WindowsPowerShell"

Write-Host -BackgroundColor Blue -ForegroundColor Black "Creating powershell directory..." -NoNewline
[void](New-Item -ItemType Directory $profileDir -Force)
Write-Host -BackgroundColor Green -ForegroundColor Black "   Created"

Write-Host -BackgroundColor Blue -ForegroundColor Black "Copying powershell profile..." -NoNewline
Copy-Item "$PSScriptRoot\Microsoft.PowerShell_profile.ps1" "$profileDir\"
Write-Host -BackgroundColor Green -ForegroundColor Black "   Copied"

Write-Host -BackgroundColor Blue -ForegroundColor Black "Adding functions (alias)..." -NoNewline
Get-Content "$PSScriptRoot\functions\*" >> "$profileDir\Microsoft.PowerShell_profile.ps1"
Write-Host -BackgroundColor Green -ForegroundColor Black "   Added"

Write-Host -BackgroundColor Blue -ForegroundColor Black "Installing Caskaydia Nerd Fonts..." -NoNewline
$fontsDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
[void](New-Item -ItemType Directory $fontsDir -Force)
$fontRegKey = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
$fontsInstalled = 0
foreach ($font in Get-ChildItem "$PSScriptRoot\fonts" -Recurse -Include '*.ttf', '*.otf') {
    $fontDest = Join-Path $fontsDir $font.Name
    # Skip already-installed fonts: re-copying a font file that is in use by another process
    # (e.g. Windows Terminal) fails with "the process cannot access the file".
    if (Test-Path $fontDest) { continue }
    Copy-Item $font.FullName $fontDest -Force
    New-ItemProperty -Path $fontRegKey -Name "$($font.BaseName) (TrueType)" -Value $fontDest -PropertyType String -Force | Out-Null
    $fontsInstalled++
}
if ($fontsInstalled -gt 0) {
    Write-Host -BackgroundColor Green -ForegroundColor Black "   Installed"
}
else {
    Write-Host -BackgroundColor Yellow -ForegroundColor Black "   Already installed"
}

Write-Host -BackgroundColor Blue -ForegroundColor Black "Syncing Windows Terminal settings..." -NoNewline
try {
    . (Join-Path $PSScriptRoot 'terminal\_terminal.ps1')
    $repoSettings   = Join-Path $PSScriptRoot 'terminal\settings.json'
    $targetSettings = Get-WindowsTerminalSettingsPath
    if (-not (Test-Path $repoSettings)) {
        Write-Host -BackgroundColor Yellow -ForegroundColor Black "   Skipped (no settings.json in repo)"
    }
    elseif (-not $targetSettings) {
        Write-Host -BackgroundColor Yellow -ForegroundColor Black "   Skipped (Windows Terminal not found)"
    }
    else {
        $targetDir = Split-Path $targetSettings -Parent
        [void](New-Item -ItemType Directory $targetDir -Force)
        if (Test-Path $targetSettings) {
            $backup = Join-Path $targetDir ("settings.backup-{0:yyyyMMdd-HHmmss}.json" -f (Get-Date))
            Copy-Item $targetSettings $backup -Force
        }
        Copy-Item $repoSettings $targetSettings -Force
        Write-Host -BackgroundColor Green -ForegroundColor Black "   Synced"
    }
}
catch {
    Write-Host -BackgroundColor Red -ForegroundColor Black "   Failed: $($_.Exception.Message)"
}