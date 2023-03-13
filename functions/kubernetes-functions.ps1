function azaccountset() {
    Write-Host -BackgroundColor White -ForegroundColor Black "Select the account:" 
    $account = & az account list -o table --query '[].name' | fzf --height 30% --layout reverse
    az account set -s $account
    az account show
}

function kubeusecontext() {
    Write-Host -BackgroundColor White -ForegroundColor Black "Select the context to use:"
    $context = & kubectl config get-contexts | fzf --height 30% --layout reverse | gawk '{print $1}'
    Write-Host $context
    if ( $context -eq "*" ){
        $context= kubectl config current-context
    }
    kubectl config use-context $context
}

function kubesetns () {
    Write-Host -BackgroundColor White -ForegroundColor Black "Select the namespace to use:"
    $ns = & kubectl get ns | fzf --height 30% --layout reverse  | gawk '{print $1}'
    kubectl config set-context --current --namespace=$ns
    Write-Host -BackgroundColor White -ForegroundColor Black "Namespace: $ns"
}