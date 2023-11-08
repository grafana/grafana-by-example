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

_waitDbStart() {
  #psql -U postgres -c "ALTER DATABASE db WITH ALLOW_CONNECTIONS false;"
  DB_STATUS=-1
  while [ $DB_STATUS -ne 0 ]; do
    sleep 2
    #psql -U postgres -c "SELECT version();"
    pg_isready
    DB_STATUS=$?
    echo "DB Status $DB_STATUS"
  done
  echo "DB Started ---------------------------"
}

# https://betterstack.com/community/guides/logging/how-to-start-logging-with-postgresql/

case "$CMD" in
  sleep)
    sleep 86400
    ;;
  run)
      #cp postgresql.conf /var/lib/postgresql/data/postgresql.conf
      #chown postgres:postgres /var/lib/postgresql/data/postgresql.conf
      /usr/local/bin/docker-entrypoint.sh postgres -c 'config_file=/postgresql.conf' &
      _waitDbStart
      ./ctl.sh create-db
      sleep 86400
    ;;
  create-db)
    psql -U postgres -c "CREATE DATABASE dvdrental;"
    pg_restore -U postgres -d dvdrental dvdrental.tar
    #psql -U postgres -c "ALTER DATABASE db WITH ALLOW_CONNECTIONS true;"
    ;;
  download)
    curl -L -O https://www.postgresqltutorial.com/wp-content/uploads/2019/05/dvdrental.zip
    tar xf dvdrental.zip
    ;;
  build)
    docker-compose build
    docker pull grafana/agent:latest
  ;;
  configure)
    # Requires
    # export GRAFANA_FARO_KEY=
    cat grafana-agent/unconfigured-config-cloud.yaml | envsubst > configured-config-cloud.yaml
  ;;
  run)
    docker run -i -t $CMD_ARG1
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
  build) # pull | all | <image-name>
    docker-compose build
    docker pull postgres:latest
    docker pull adminer
    docker pull grafana/agent:latest
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
  db-test)
    ./postgres-metrics/postgres-metrics.py db-test
    ;;
  test)
    echo "test"
    ;;
  *)
    echo "Command not recognized [$@]"
    echo "Help:"
    echo "  download"
    echo "  build"
    echo "  local up"
    echo "  local down"
    echo "  sh | bash <container-name>"
    ;;
esac

