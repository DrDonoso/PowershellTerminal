Write-Host -BackgroundColor Blue -ForegroundColor Black "Creating powershell directory..." -NoNewline
[void](New-Item -ItemType Directory "$env:USERPROFILE\Documents\WindowsPowerShell" -Force)
Write-Host -BackgroundColor Green -ForegroundColor Black "   Created"

Write-Host -BackgroundColor Blue -ForegroundColor Black "Copying powershell profile..." -NoNewline
Copy-Item Microsoft.PowerShell_profile.ps1 "$env:USERPROFILE\Documents\WindowsPowerShell\"
Write-Host -BackgroundColor Green -ForegroundColor Black "   Copied"

Write-Host -BackgroundColor Blue -ForegroundColor Black "Adding functions (alias)..." -NoNewline
Get-Content .\functions\* >> "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
Write-Host -BackgroundColor Green -ForegroundColor Black "   Added"