#!/bin/bash
#
#
CMD=${1:-"help"}
CMD_ARG1=${2:-"test1"}

# Requires:
## envsubst

GRAFANA_PROMTAIL_CONFIG_FILE="promtail-config.yml"
SHARED_DIR="container_dir"
DOWNLOADS_DIR="downloads"
GRAFANA_AGENT_VERSION="v0.24.1"
DOCKER_FILES_DIR="dockerfiles"
DOCKER_COMPOSE_DIR="docker-compose"
UNCONFIGURE_FILE="unconfigure.sh"

_getContainerIdFromName() {
  DOCKER_IMAGE_NAME=$1
  CONTAINER_ID=$(docker ps --format '{{json .}}' \
    | jq -r --arg DOCKER_IMAGE_NAME "$DOCKER_IMAGE_NAME" 'select(.Names | contains($DOCKER_IMAGE_NAME)) | .ID')
  echo $CONTAINER_ID
}

case "$CMD" in
  configure)
  ;;
  run)
    docker run -i -t $CMD_ARG1 bash
  ;;
  up|start)
    docker-compose -f docker-compose.yaml up -d
    #docker-compose -f docker-compose.yaml up
  ;;
  upd|startd)
    docker-compose -f docker-compose.yaml up -d
    #docker-compose -f docker-compose.yml up
  ;;
  down|stop)
    docker-compose -f docker-compose.yaml down
  ;;
  logs)
    CONTAINER_ID=$(_getContainerIdFromName $2)
    docker logs $CONTAINER_ID -f
    ;;
  ps)
    docker ps --format "{{.ID}} {{.Names}}"
    ;;
  bash|sh)
    CONTAINER_ID=$(_getContainerIdFromName $2)
    echo "$1 to container: $2 id: ID"
    docker exec -it $CONTAINER_ID $1
  ;;
  build) # pull | all | <image-name>
    docker-compose build
  ;;
  test)
    echo "test"
    ;;
  *)
    echo "Command not recognized [$@]"
    echo "Help:"
    echo "  configure"
    echo "  build"
    echo "  start"
    echo "  stop"
    echo "  sh | bash <container>"
    ;;
esac
