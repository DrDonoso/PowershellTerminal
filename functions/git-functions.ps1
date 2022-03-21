function gitb($1) {
    git checkout -b $1
    git push --set-upstream origin $1
}

function gitcp($1) {
    git add .
    git commit -m $1
    git push
}