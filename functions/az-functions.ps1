function azaccountset() {
    Write-Host -BackgroundColor Blue -ForegroundColor Black "Select the account:" -NoNewline
    $account = & az account list -o table --query '[].name' | fzf --height 30% --layout reverse
    az account set -s $account
    az account show
}