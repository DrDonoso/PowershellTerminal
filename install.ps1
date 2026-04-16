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