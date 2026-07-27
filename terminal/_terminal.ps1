# Shared helper for the Windows Terminal settings sync. Dot-sourced via $PSScriptRoot, e.g.:
#   . (Join-Path $PSScriptRoot 'terminal\_terminal.ps1')

function Get-WindowsTerminalSettingsPath {
    # Returns the path to this machine's Windows Terminal settings.json.
    # Prefers a file that already exists; otherwise returns the first candidate whose LocalState
    # folder exists (Terminal installed but settings not written yet). Returns $null if none apply.
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json')
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json')
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json')
    )
    $existing = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($existing) { return $existing }
    foreach ($c in $candidates) {
        if (Test-Path (Split-Path $c -Parent)) { return $c }
    }
    return $null
}
