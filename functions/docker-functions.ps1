function drm {
    docker rm -f $(docker ps -a -q)
}

function dlogs() {
    Write-Host -BackgroundColor White -ForegroundColor Black "Select the container to view logs:"
    $container = & docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" | fzf --height 30% --layout reverse | gawk '{print $1}'
    if ($container -eq "") {
        Write-Host -BackgroundColor Red -ForegroundColor White "No container selected."
        return
    }
    Write-Host -BackgroundColor White -ForegroundColor Black "Fetching logs for container: $container"
    docker logs $container --tail 50
}

function dlogsf() {
    Write-Host -BackgroundColor White -ForegroundColor Black "Select the container to view logs with follow:"
    $container = & docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" | fzf --height 30% --layout reverse | gawk '{print $1}'
    if ($container -eq "") {
        Write-Host -BackgroundColor Red -ForegroundColor White "No container selected."
        return
    }
    Write-Host -BackgroundColor White -ForegroundColor Black "Fetching logs for container: $container"
    docker logs $container --tail 50 -f
}

function denter() {
    Write-Host -BackgroundColor White -ForegroundColor Black "Select the container to enter:"
    $container = & docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" | fzf --height 30% --layout reverse | gawk '{print $1}'
    if ($container -eq "") {
        Write-Host -BackgroundColor Red -ForegroundColor White "No container selected."
        return
    }
    Write-Host -BackgroundColor White -ForegroundColor Black "Entering container: $container"
    docker exec -it $container sh
}