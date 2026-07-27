# Shared helpers for the tools/*.ps1 installers. Dot-sourced via $PSScriptRoot, e.g.:
#   . (Join-Path $PSScriptRoot '_common.ps1')
# Provides an animated "installing" spinner that is replaced by "installed"/"failed", so each
# installer keeps a clean, aligned single line per package instead of dumping the tool's own log.

$script:SpinnerFrames = '|', '/', '-', '\'

function Get-InstallPrefix {
    param([string]$Label)
    return '  ' + $Label.PadRight(20) + ' '
}

function Show-InstallResult {
    param(
        [string]$Prefix,
        [bool]$Ok,
        [string[]]$ErrorLines = @()
    )
    if ($Ok) {
        # `r returns to the start of the line; trailing spaces clear the leftover "installing X"
        Write-Host ("`r{0}installed        " -f $Prefix) -ForegroundColor Green
    }
    else {
        Write-Host ("`r{0}failed           " -f $Prefix) -ForegroundColor Red
        foreach ($line in $ErrorLines) {
            if ($line -and "$line".Trim()) { Write-Host "      $line" -ForegroundColor DarkGray }
        }
    }
}

function Invoke-NativeWithSpinner {
    # Runs a native executable while animating a spinner, then prints installed/failed.
    # Returns $true on success. On failure the last lines of the tool's output are shown.
    param(
        [Parameter(Mandatory)][string]$Label,
        [Parameter(Mandatory)][string]$FilePath,
        [string[]]$Arguments = @(),
        [int[]]$SuccessExitCodes = @(0)
    )
    $prefix  = Get-InstallPrefix -Label $Label
    $outFile = [System.IO.Path]::GetTempFileName()
    $errFile = [System.IO.Path]::GetTempFileName()
    try {
        $proc = Start-Process -FilePath $FilePath -ArgumentList $Arguments -NoNewWindow -PassThru `
            -RedirectStandardOutput $outFile -RedirectStandardError $errFile
        $i = 0
        while (-not $proc.HasExited) {
            Write-Host ("`r{0}installing {1}" -f $prefix, $script:SpinnerFrames[$i % 4]) -NoNewline -ForegroundColor Cyan
            Start-Sleep -Milliseconds 120
            $i++
        }
        $proc.WaitForExit()
        $ok = $SuccessExitCodes -contains $proc.ExitCode

        $errLines = @()
        if (-not $ok) {
            $errLines = @(Get-Content $errFile -ErrorAction SilentlyContinue) +
                        @(Get-Content $outFile -ErrorAction SilentlyContinue)
            $errLines = @($errLines | Where-Object { $_ -and "$_".Trim() } | Select-Object -Last 15)
            if (-not $errLines) { $errLines = @("exit code $($proc.ExitCode)") }
        }
        Show-InstallResult -Prefix $prefix -Ok $ok -ErrorLines $errLines
        return $ok
    }
    finally {
        Remove-Item $outFile, $errFile -Force -ErrorAction SilentlyContinue
    }
}

function Invoke-JobWithSpinner {
    # Runs a scriptblock (e.g. a cmdlet like Install-Module) in a background job with a spinner.
    # The scriptblock must THROW on failure. Pass caller values through -ArgumentList (a param()
    # block), not $using:, because the job is started inside this function's scope.
    param(
        [Parameter(Mandatory)][string]$Label,
        [Parameter(Mandatory)][scriptblock]$Work,
        [object[]]$ArgumentList = @()
    )
    $prefix = Get-InstallPrefix -Label $Label
    if (Get-Command Start-ThreadJob -ErrorAction SilentlyContinue) {
        $job = Start-ThreadJob -ScriptBlock $Work -ArgumentList $ArgumentList
    }
    else {
        $job = Start-Job -ScriptBlock $Work -ArgumentList $ArgumentList
    }
    $i = 0
    while ($job.State -eq 'NotStarted' -or $job.State -eq 'Running') {
        Write-Host ("`r{0}installing {1}" -f $prefix, $script:SpinnerFrames[$i % 4]) -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 120
        $i++
    }
    $err = $null
    try { Receive-Job -Job $job -Wait -ErrorAction Stop *> $null }
    catch { $err = $_.Exception.Message }
    Remove-Job -Job $job -Force -ErrorAction SilentlyContinue

    $ok = -not $err
    Show-InstallResult -Prefix $prefix -Ok $ok -ErrorLines (@($err) | Where-Object { $_ })
    return $ok
}
