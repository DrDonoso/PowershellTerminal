function gitb($1) {
    git checkout -b $1
    git push --set-upstream origin $1
}

function repos {
    Set-Location C:\Repos
}

function touch($1) {
    New-Item $1
}

function test {
    Set-Location C:\
}
