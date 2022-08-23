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
    if [ $(which envsubst) = "" ]; then
      echo "envsubst is missing"
      exit 1
    fi
    # Configure Docker Compose config
    export GRAFANA_TRACES_OTEL_AUTH_HEADER=$(echo -n "$GRAFANA_TRACES_USERNAME:$GRAFANA_TRACES_API_KEY" | base64)
    DST_CONFIG_FILE="configured-otel-config.yaml"
    SRC_CONFIG_FILE="otel-config.yaml"
    cat $SRC_CONFIG_FILE | envsubst > $DST_CONFIG_FILE
    echo "Created: $DST_CONFIG_FILE"
    echo "rm $DST_CONFIG_FILE" > $UNCONFIGURE_FILE
   
    # Configure Grafana Agent
    # GRAFANA_METRICS_*, GRAFANA_LOGS_*, GRAFANA_TRACES_*
    DST_CONFIG_FILE="configured-grafana-agent-config.yaml"
    SRC_CONFIG_FILE="grafana-agent-config.yaml"
    cat $SRC_CONFIG_FILE | envsubst > $DST_CONFIG_FILE
    echo "Created: $DST_CONFIG_FILE"
    echo "rm $DST_CONFIG_FILE" >> $UNCONFIGURE_FILE
  ;;
  run)
    docker run -i -t $CMD_ARG1 bash
  ;;
  up)
    docker-compose -f docker-compose.yml up -d
  ;;
  down)
    docker-compose -f docker-compose.yml down
  ;;
  logs)
    CONTAINER_ID=$(_getContainerIdFromName $2)
    docker logs $CONTAINER_ID
    ;;
  bash|sh)
    CONTAINER_ID=$(_getContainerIdFromName $2)
    echo "$1 to container: $2 id: ID"
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
