function drm {
    docker rm -f $(docker ps -a -q)
  }