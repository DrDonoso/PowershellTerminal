function repos {
    Set-Location C:\Repos
}

function touch($1) {
    New-Item $1
}

New-Alias -Name tf -Value terraform.exe