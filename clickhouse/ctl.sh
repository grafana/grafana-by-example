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

CH_DOWNLOADS_DIR="clickhouse-data/downloads"
STOCK_LIST=("msft" "aapl" "tsla" "wm" "swks" "csco" "^GSPC" "^IXIC")

_durationToSeconds() {
  DURATION_SEC=$1
  DURATION_SEC_LAST_CHAR=${DURATION_SEC: -1}
  if [ "$DURATION_SEC_LAST_CHAR" == "s" ]; then
    RESULT=$(( ${DURATION_SEC%?} * 1 ))
  elif [ "$DURATION_SEC_LAST_CHAR" == "m" ]; then
    RESULT=$(( ${DURATION_SEC%?} * 60 ))
  elif [ "$DURATION_SEC_LAST_CHAR" == "h" ]; then
    RESULT=$(( ${DURATION_SEC%?} * 60 * 60 ))
  elif [ "$DURATION_SEC_LAST_CHAR" == "d" ]; then
    RESULT=$(( ${DURATION_SEC%?} * 60 * 60 * 24 ))
  elif [ "$DURATION_SEC_LAST_CHAR" == "w" ]; then
    RESULT=$(( ${DURATION_SEC%?} * 60 * 60 * 60 * 7 ))
  else
    RESULT=$DURATION_SEC
  fi
  echo $RESULT
}

_downloadStockData() {
  STOCK_SYMBOL=${1:-"aapl"}
  DURATION=${2:-"1w"}
  NOW_SEC=$(date +%s)
  DURATION_SEC=$(_durationToSeconds $DURATION)
  START_SEC=$(( NOW_SEC - DURATION_SEC ))
  CSV_FILE=$STOCK_SYMBOL.csv
  PERIOD1=$START_SEC
  PERIOD2=$NOW_SEC
  INTERVAL="1d"
  echo "Downloading symbol: $STOCK_SYMBOL from: $START_SEC to: $NOW_SEC duration: $DURATION_SEC to: $CSV_FILE" 
  curl -L -o $CSV_FILE "https://query1.finance.yahoo.com/v7/finance/download/$STOCK_SYMBOL?period1=$PERIOD1&period2=$PERIOD2&interval=$INTERVAL&events=history"
  sed -i 1d $CSV_FILE # Delete first line headers, CSV or CSVWithNames
  sed -i "1,$ s/^/$STOCK_SYMBOL,/" $CSV_FILE # Start at line 1
  #sed -i  '1 s/^/Symbol,/' $CSV_FILE # Add Symbol, to first line
}

_dbLoadStocksCSV() {
  STOCK_SYMBOL_FILE=${1:-"aapl.csv"}
  cat $STOCK_SYMBOL_FILE | clickhouse-client --host clickhouse-server --format_csv_delimiter="," \
                  --query="INSERT INTO stocks FORMAT CSV"
  clickhouse-client --host clickhouse-server --query="OPTIMIZE TABLE stocks DEDUPLICATE by symbol, date"
}

_getContainerIdFromName() {
  DOCKER_IMAGE_NAME=$1
  CONTAINER_ID=$(docker ps --format '{{json .}}' \
    | jq -r --arg DOCKER_IMAGE_NAME "$DOCKER_IMAGE_NAME" 'select(.Names | contains($DOCKER_IMAGE_NAME)) | .ID')
  echo $CONTAINER_ID
}

_downloadDatabaseData() {
  TARGET_DOWNLOAD_URL="https://datasets.clickhouse.com/cell_towers.csv.xz"
  REQUIRED_FILE1="$CH_DOWNLOADS_DIR/cell_towers.csv.xz"
  REQUIRED_FILE2="$CH_DOWNLOADS_DIR/cell_towers.csv"
  echo "Checking for $REQUIRED_FILE2"
  if [ ! -f $REQUIRED_FILE2 ]; then
    echo "Downloading $TARGET_DOWNLOAD_URL to $REQUIRED_FILE1"
    if [ ! -f $REQUIRED_FILE1 ]   && [ "$(which curl)" != "" ] ; then
      curl -L -O $TARGET_DOWNLOAD_URL $CH_DOWNLOADS_DIR
    elif [ ! -f $REQUIRED_FILE1 ] && [ "$(which wget)" != "" ] ; then
      wget -v $TARGET_DOWNLOAD_URL -P $CH_DOWNLOADS_DIR
    else
      echo "Error: Unable to download: curl and wget appear missing" 
    fi
  else
    echo "Already exists: $REQUIRED_FILE2"
  fi
}

_createDatabase_cell_towers() {
  # Run from the ClickHouse Server
  # https://clickhouse.com/docs/en/getting-started/example-datasets/cell-towers
  CSV_FILE="cell_towers.csv"
  # Takes about minutes to compelete
  echo "Start: $(date)"
  apt-get -y update
  apt-get -y install xz-utils
  if [ ! -f $CH_DOWNLOADS_DIR/cell_towers.csv ]; then
    xz -d $CH_DOWNLOADS_DIR/cell_towers.csv.xz
  fi
  R=$(clickhouse-client --query "select count(*) from cell_towers")
  if [ "$R" != "" ]; then
    echo "Table cell_towers rows: [$R]" # Expected 43276158 rows
    if [ "$R" -lt 40276158 ]; then
      echo "loading cell_towers"
      clickhouse-client --queries-file clickhouse/create-table-cell-towers.sql
      clickhouse-client --query "INSERT INTO cell_towers FORMAT CSV" < $CH_DOWNLOADS_DIR/cell_towers.csv
    else
      echo "cell_towers already loaded"
    fi
  else
    echo "Error querying default [$R]"
  fi
  echo "End: $(date)"
}

_buildDockerContainers() {
    CMD_ARG=${1:-"all"}
    #docker build -t syslog-ng-server -f dockerfiles/syslog-ng-server.Dockerfile .
    #docker build -t ubuntu-server -f dockerfiles/ubuntu-server.Dockerfile .
    #docker build -t clickhouse-server -f dockerfiles/clickhouse-server.Dockerfile .
    START_SEC=$(date +%s)
    if [ "$CMD_ARG" == "pull" ]; then
      IMAGE_LIST=(clickhouse/clickhouse-server grafana/agent:latest grafana/mimir:latest ubuntu:latest grafana/grafana:latest grafana/loki:latest syslog-ng-server:latest)
      for IMAGE_NAME in ${IMAGE_LIST[@]}; do
        echo $IMAGE_NAME
        docker pull $IMAGE_NAME
      done
      DOCKER_FILE_LIST=""
    elif [ "$CMD_ARG" == "all" ]; then
      DOCKER_FILE_LIST=$(cat $DOCKER_FILES_DIR/buildlist)
    else
      DOCKER_FILE_LIST=$CMD_ARG.Dockerfile
    fi
    for DOCKER_FILE in $DOCKER_FILE_LIST; do
      DOCKER_TAG=${DOCKER_FILE%.*}
      clear
      echo "-----------------------------------------------------------"
      echo "Bulding: Docker build Tag: $DOCKER_TAG File: $DOCKER_FILE"
      docker build -t $DOCKER_TAG -f $DOCKER_FILES_DIR/$DOCKER_FILE .
      if [ "$?" != "0" ]; then
        echo "Exitig with error: $?"
        exit 1
      fi
    done
    END_SEC=$(date +%s)
    DUR_SEC=$((END_SEC - START_SEC))
    echo "Complete: Build Time: $DUR_SEC Seconds"
}

_stockLoadGen() {
  STOCK_LIST_LEN=${#STOCK_LIST[@]}
  RND_N=$(( RANDOM % STOCK_LIST_LEN ))
  STOCK_SYMBOL="${STOCK_LIST[RND_N]}"
  echo "Loadgen for $STOCK_SYMBOL"
  clickhouse-client --query "SELECT * FROM stocks WHERE symbol='$STOCK_SYMBOL'"
}

case "$CMD" in
  clickhouse)
    case "$CMD_ARG1" in
      create-tables)
        clickhouse-client --host clickhouse-server --queries-file clickhouse/create-table-cell-towers.sql
        clickhouse-client --host clickhouse-server --queries-file clickhouse/create-table-stocks.sql
      ;;
      load-stock-data)
        _dbLoadStocksCSV $CMD_ARG2 
      ;;
      load-all-stocks)
        STOCK_LIST=("msft" "aapl" "tsla" "wm" "swks" "csco" "^GSPC" "^IXIC")
        for STOCK in ${STOCK_LIST[@]}; do
          _downloadStockData $STOCK "5w"
          _dbLoadStocksCSV $STOCK.csv
        done
      ;;
      entrypoint)
        # Original Clickhouse container entry point
        ./entrypoint.sh &
        ./ctl.sh clickhouse healthly
        ./ctl.sh clickhouse create-tables
        ./ctl.sh clickhouse load-all-stocks
        while (1); do
          _stockLoadGen
          sleep 5
        done
        sleep 1209600
      ;;
      healthly)
        while (true); do
          clickhouse-client --query "show databases"
          ERROR_STATE=$?
          if [ "$ERROR_STATE" == "0" ]; then
            echo "Database ready"
            break
          fi
          echo "Waiting on database"
          sleep 5
        done
      ;;
      load-gen)
        _stockLoadGen
      ;;
      *)
        echo "Command: [$CMD] Argument: [$CMD_ARG1] not recognized [$@]"
      ;;
    esac
  ;;
  configure)
    mkdir -p $CH_DOWNLOADS_DIR
    _buildDockerContainers
    _downloadDatabaseData
  ;;
  entrypoint-grafana)
    grafana-cli plugins install grafana-clickhouse-datasource
  ;;
  entrypoint|entrypoint-clickhouse)
    ./entrypoint.sh &
    while (true); do 
      RND_N=$(( RANDOM % 50000 ))
      echo "Running queries: 1 [$RND_N]"
      clickhouse-client --query "SELECT count(*) FROM cell_towers WHERE samples > $RND_N"
      if [ "$RND_N" -gt "25000" ]; then
        echo "Running queries: 2"
        clickhouse-client --query "SELECT mcc, count() FROM cell_towers GROUP BY mcc ORDER BY count() DESC LIMIT 10"
      fi
      if [ "$RND_N" -gt "40000" ]; then
        echo "Running queries: 3"
        clickhouse-client --query "SELECT radio, count() AS c FROM cell_towers GROUP BY radio ORDER BY c DESC"
      fi
      sleep 5
    done
    sleep 1209600
  ;;
  database-create)
    _createDatabase_cell_towers
    ;;
  start)
    sudo service clickhouse-server restart
  ;;
  stop)
    sudo service clickhouse-server stop
  ;;
  build) # pull | all | <image-name>
    _buildDockerContainers $CMD_ARG1 
  ;;
  cloud-configure)
    # Configure Docker Compose config
    DST_CONFIG_FILE="docker-compose-cloud-configured.yml"
    SRC_CONFIG_FILE="docker-compose-cloud-unconfigured.yml"
    cat $SRC_CONFIG_FILE | envsubst > $DST_CONFIG_FILE
    echo "Created: $DST_CONFIG_FILE"
    echo "rm $DST_CONFIG_FILE" > $UNCONFIGURE_FILE
   
    # Configure Grafana Agent
    # GRAFANA_METRICS_*, GRAFANA_LOGS_*, GRAFANA_TRACES_*
    DST_CONFIG_FILE="agent/config-cloud-configured.yaml"
    SRC_CONFIG_FILE="agent/config-cloud-unconfigured.yaml"
    cat $SRC_CONFIG_FILE | envsubst > $DST_CONFIG_FILE
    echo "Created: $DST_CONFIG_FILE"
    echo "rm $DST_CONFIG_FILE" >> $UNCONFIGURE_FILE
  
    # Configure Prometheus
    # Not used for cloud
    #DST_CONFIG_FILE="prometheus/prometheus-cloud-configured.yml"
    #SRC_CONFIG_FILE="prometheus/prometheus-cloud-unconfigured.yml"
    #echo "Created: $DST_CONFIG_FILE"
    #echo "rm $DST_CONFIG_FILE" >> $UNCONFIGURE_FILE
  ;;
  run)
    docker run -i -t $CMD_ARG1 bash
  ;;
  local)
    case "$CMD_ARG1" in
      up)
        docker-compose -f docker-compose.yaml up -d
        sleep 5
        docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Command}}"
        #echo "Following logs from docker-compose"
        #docker-compose logs -f
      ;;
      down)
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
  syslog-test1)
    loggen -I 10 --syslog-proto --inet grafana1.home 6601
    loggen -I 10 --syslog-proto --dgram  grafana1 5514
  ;;
  syslog-test2)
    # TCP
    loggen  -I 60 --syslog-proto --inet  localhost 6601
    # UDP
    loggen  -I 60 --syslog-proto --dgram  localhost 5514
  ;;
  download-stock-data)
    STOCK_SYMBOL=${2:-"aapl"}
    DURATION=${3:-"1w"}
    _downloadStockData $STOCK_SYMBOL $DURATION
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

