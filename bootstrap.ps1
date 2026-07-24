$ErrorActionPreference = 'Stop'

$repo   = 'DrDonoso/PowershellTerminal'
$branch = 'main'

# Allow running the downloaded install.ps1 in this process (default policy is Restricted)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Speed up Invoke-WebRequest and enable TLS 1.2 on older systems
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$tmpDir  = Join-Path $env:TEMP "pwsh-terminal-$([guid]::NewGuid())"
$zipPath = "$tmpDir.zip"

try {
    Write-Host -BackgroundColor Blue -ForegroundColor Black "Downloading repository..." -NoNewline
    Invoke-WebRequest -Uri "https://github.com/$repo/archive/refs/heads/$branch.zip" -OutFile $zipPath
    Write-Host -BackgroundColor Green -ForegroundColor Black "   Downloaded"

    Write-Host -BackgroundColor Blue -ForegroundColor Black "Extracting archive..." -NoNewline
    Expand-Archive -Path $zipPath -DestinationPath $tmpDir -Force
    Write-Host -BackgroundColor Green -ForegroundColor Black "   Extracted"

    $repoName      = ($repo -split '/')[-1]
    $base          = Join-Path $tmpDir "$repoName-$branch"
    $toolsDir      = Join-Path $base 'tools'
    $toolScripts   = @('winget.ps1', 'ps.ps1', 'choco.ps1') | ForEach-Object { Join-Path $toolsDir $_ }
    $installScript = Join-Path $base 'install.ps1'
    foreach ($script in ($toolScripts + $installScript)) {
        if (-not (Test-Path $script)) {
            throw "Script not found at '$script'."
        }
    }

    foreach ($script in $toolScripts) { & $script }

    Write-Host -BackgroundColor Blue -ForegroundColor Black "Installing terminal profile..."
    & $installScript
}
finally {
    Write-Host -BackgroundColor Blue -ForegroundColor Black "Cleaning up temporary files..." -NoNewline
    Remove-Item -Path $zipPath, $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host -BackgroundColor Green -ForegroundColor Black "   Done"
}
