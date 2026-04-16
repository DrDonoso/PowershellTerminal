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

function kubelogs() {
    Write-Host -BackgroundColor White -ForegroundColor Black "Select the pod to view logs:"
    $pod = & kubectl get pods -o wide | fzf --height 30% --layout reverse | gawk '{print $1}'
    if ($pod -eq "") {
        Write-Host -BackgroundColor Red -ForegroundColor White "No pod selected."
        return
    }
    Write-Host -BackgroundColor White -ForegroundColor Black "Fetching logs for pod: $pod"
    kubectl logs $pod --tail=100
}

function kubelogsf() {
    Write-Host -BackgroundColor White -ForegroundColor Black "Select the pod to view logs with follow:"
    $pod = & kubectl get pods -o wide | fzf --height 30% --layout reverse | gawk '{print $1}'
    if ($pod -eq "") {
        Write-Host -BackgroundColor Red -ForegroundColor White "No pod selected."
        return
    }
    Write-Host -BackgroundColor White -ForegroundColor Black "Fetching logs for pod: $pod"
    kubectl logs $pod --tail=100 -f
}

function kubedescribepod() {
    Write-Host -BackgroundColor White -ForegroundColor Black "Select the pod to describe:"
    $pod = & kubectl get pods -o wide | fzf --height 30% --layout reverse | gawk '{print $1}'
    if ($pod -eq "") {
        Write-Host -BackgroundColor Red -ForegroundColor White "No pod selected."
        return
    }
    Write-Host -BackgroundColor White -ForegroundColor Black "Describing pod: $pod"
    kubectl describe pod $pod
}