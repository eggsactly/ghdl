#!/usr/bin/env sh

set -e

if [ $# -ne 2 ] ; then
  echo "Usage: $(basename $0)"
  exit 1
else
  docker images
  docker login -u="$DOCKER_USER" -p="$DOCKER_PASS"
  docker push "ghdl/builder"
  docker push "ghdl/runner"
  #docker push 
  #for tag in $2; do
  #  echo "[DEPLOY] Pushing $tag[-$1]..."
  #  docker push "ghdl/portainer:$tag-$1"
  #  docker push "ghdl/portainer:$tag"
  #done
  docker logout
  #exit 0
fi
