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

function gitclean() {
    git fetch --prune

    $branches = git for-each-ref --format '%(refname:short) %(committerdate:unix)' refs/heads/ |
        ForEach-Object {
            $splitResult = $_ -split " "
            
            if ($splitResult.Length -eq 2) {
                $branch = $splitResult[0]
                $timestamp = $splitResult[1]
    
                if ([long]::TryParse($timestamp, [ref]$null)) {
                    try {
                        $epoch = [datetime]'1970-01-01T00:00:00Z'
                        $dateOfCommit = $epoch.AddSeconds([double]$timestamp)
                        $ageInSeconds = (Get-Date) - $dateOfCommit
                        $daysSinceCommit = [math]::Floor($ageInSeconds.TotalDays)
    
                        return [PSCustomObject]@{
                            Branch = $branch
                            DaysSinceCommit = $daysSinceCommit
                        }
                    } catch {
                        Write-Host "Error calculating the age of branch '$branch'. Error: $_"
                    }
                } else {
                    Write-Host "Error: Timestamp is not a valid number. Branch: '$branch', Timestamp: '$timestamp'"
                }
            }
        }

    $deletedCount = 0
    foreach ($branchInfo in $branches) {
        $branch = $branchInfo.Branch
        $daysSinceCommit = $branchInfo.DaysSinceCommit

        if ($branch -notin @('main', 'master', 'develop')) {
            Write-Host -ForegroundColor Yellow -NoNewline "⚠️ Do you want to delete the branch '$branch' (last commit $daysSinceCommit days ago)? (Y/n) "
            $confirmation = Read-Host
            if ($confirmation -eq '' -or $confirmation -eq 'y' -or $confirmation -eq 'Y') {
                git branch -D $branch
                Write-Host "🗑️ Deleting branch: $branch"
                $deletedCount++
            } else {
                Write-Host "Did not delete the branch: $branch"
            }
        } else {
            Write-Host "Skipping protected branch: $branch"
        }
    }

    Write-Host "Deleted $deletedCount branches."
}