function gitb($1) {
    git checkout -b $1
    git push --set-upstream origin $1
}

function gitcp($1) {
    git add .
    if($1){
        Write-Host -BackgroundColor White -ForegroundColor Black "Commit message: $1"
        git commit -m $1
    } else {
        Write-Host -BackgroundColor White -ForegroundColor Black "Commit message:"
        aicommits
    }
    git push
}

function gitcb() {
    $branch = & git branch -l | fzf --height 30% --layout reverse
    $branch = $branch.Trim()
    git checkout $branch
}