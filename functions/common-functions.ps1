function repos {
    Set-Location C:\Repos
}

function touch($1) {
    New-Item $1
}
