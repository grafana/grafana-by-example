#!/bin/bash
#
#
CMD=${1:-"help"}
CMD_ARG1=${2:-""}
CMD_ARG2=${3:-""}

SHARED_DIR="container_dir"
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
    # Requires
    # export GRAFANA_FARO_KEY=
    cat unconfigured-index.html | envsubst > configured-index.html
  run)
    docker run -i -t $CMD_ARG1 bash
  ;;
  local)
    case "$CMD_ARG1" in
      up|start)
        docker-compose -f docker-compose.yaml up -d
        sleep 5
        docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Command}}"
        #echo "Following logs from docker-compose"
        #docker-compose logs -f
      ;;
      down|stop)
        docker-compose -f docker-compose.yaml down
      ;;
      restart)
        docker-compose -f docker-compose.yaml down
        echo "Down"
        docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Command}}"
        docker-compose -f docker-compose.yaml up -d
        echo "Up"
        docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Command}}"
      ;;
      *)
        echo "Command: [$CMD] Argument: [$CMD_ARG1] not recognized [$@]"
      ;;
    esac
  ;;
  cloud-up)
    docker-compose -f docker-compose-cloud-configured.yml up -d
    sleep 5
    #echo "Following docker-compose logs"
    #docker-compose logs -f
  ;;
  cloud-down)
    docker-compose -f docker-compose-cloud-configured.yml down
  ;;
  logs-d)
    docker-compose logs -f
    ;;
  logs-c)
    CONTAINER_ID=$(_getContainerIdFromName $2)
    docker logs $CONTAINER_ID
    ;;
  bash|sh)
    CONTAINER_ID=$(_getContainerIdFromName $2)
    echo "Conencting $1 to container: $2 id: $CONTAINER_ID"
    docker exec -it $CONTAINER_ID $1
  ;;
  test)
    echo "test"
    ;;
  *)
    echo "Command not recognized [$@]"
    echo "Help:"
    echo "  cloud-configure"
    echo "  cloud-up"
    echo "  cloud-down"
    echo "  sh | bash <container>"
    ;;
esac

