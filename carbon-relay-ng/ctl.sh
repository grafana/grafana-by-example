#!/bin/bash
#
#

# node exporter dashboard https://grafana.com/grafana/dashboards/1860

PROMETHEUS_VER=2.29.2
PROMTHEUS_TAR=prometheus-${PROMETHEUS_VER}.linux-amd64
PROMTHEUS_DIR=${PROMTHEUS_TAR}

NODE_EXPORTER_VER=1.2.2
NODE_EXPORTER_TAR=node_exporter-${NODE_EXPORTER_VER}.linux-amd64
NODE_EXPORTER_DIR=${NODE_EXPORTER_TAR}

GRAFANA_VER=8.1.2
GRAFANA_TAR=grafana-enterprise-${GRAFANA_VER}.linux-amd64
GRAFANA_DIR=grafana-${GRAFANA_VER}

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

UNCONFIGURE_FILE="unconfigure.sh"
DOCKER_IMAGE="carbon-relay-ng"
CMD=${1:-"Missing"}


case "$CMD" in
  build)
    DOCKER_IMAGE_NAME=${2:-"$DOCKER_IMAGE"}
    docker build -t $DOCKER_IMAGE_NAME -f $DOCKER_IMAGE_NAME.Dockerfile .
    ;;
  run)
    DOCKER_IMAGE_NAME=${2:-"$DOCKER_IMAGE"}
    docker run -it $DOCKER_IMAGE_NAME
    ;;
  cloud-configure)
    # Configure Docker Compose config
    DST_CONFIG_FILE="carbon-relay-ng-configured.ini"
    SRC_CONFIG_FILE="carbon-relay-ng-unconfigured.ini"
    cat $SRC_CONFIG_FILE | envsubst > $DST_CONFIG_FILE
    echo "Created: $DST_CONFIG_FILE"
    echo "rm $DST_CONFIG_FILE" > $UNCONFIGURE_FILE
    ;;
  up)
    docker-compose -f docker-compose.yml up -d
  ;;
  down)
    docker-compose -f docker-compose.yml down
  ;;
  configure)
    # Nothing to configure
    ;;
  start)
    nohup /bin/carbon-relay-ng /etc/carbon-relay-ng/carbon-relay-ng.ini &
    sleep 15
    #./ctl.sh send-metrics-random
    ./ctl.sh send-metrics-wave
    ;;
  send-metrics-random)
    DURATION="1h"
    INTERVAL_SEC=15
    DURATION_SEC=$(_durationToSeconds ${DURATION})
    START_TIME=$(date +%s)
    END_TIME=$(( START_TIME + DURATION_SEC ))
    CNT_I=0
    while (true); do
      CNT_I=$((CNT_I+1))
      TIME_NOW=$(date +%s)
      TIME_REMAINING=$((END_TIME - TIME_NOW))
      number=$((RANDOM % 6 + 1));
      sampleN=$((RANDOM % 3 + 1));
      DATA_STR="local.random.sample${sampleN} ${number} ${TIME_NOW}"
      echo $CNT_I $DATA_STR
      echo $DATA_STR | nc -q 1 localhost 2003
      #echo $DATA_STR | nc 0.0.0.0 2003 &
      if [ "$TIME_NOW" -gt "$END_TIME" ]; then
        echo "Stopping "
        break;
      else
        sleep $INTERVAL_SEC
      fi
    done
   ;;
  send-metrics-wave)
    DURATION="24h"
    PEAK_DURATION=5m
    INTERVAL_SEC=15
    DIRECTION=1
    SAMPLE_VALUE=1
    SAMPLE_STEP=5
    DURATION_SEC=$(_durationToSeconds ${DURATION})
    PEAK_DURATION_SEC=$(_durationToSeconds ${PEAK_DURATION})
    DIRECTION_CHANGE_TIME=$(( $(date +%s) + $(_durationToSeconds ${PEAK_DURATION_SEC}) ))
    START_TIME=$(date +%s)
    END_TIME=$(( START_TIME + DURATION_SEC * DIRECTION ))
    CNT_I=0
    while (true); do
      CNT_I=$((CNT_I+1))
      TIME_NOW=$(date +%s)
      TIME_REMAINING=$((END_TIME - TIME_NOW))
      SAMPLE_VALUE=$((SAMPLE_VALUE + SAMPLE_STEP * DIRECTION))
      number=$((RANDOM % 6 + 1));
      sampleN=1
      DATA_STR="local.wave.sample${sampleN} ${SAMPLE_VALUE} ${TIME_NOW}"
      echo $CNT_I $DATA_STR
      echo $DATA_STR | nc -q 1 localhost 2003
      #echo $DATA_STR | nc -q 1 localhost 2003
      #echo $DATA_STR | nc 0.0.0.0 2003 &
      if [ "$TIME_NOW" -gt "$END_TIME" ]; then
        echo "Stopping "
        break;
      else
        sleep $INTERVAL_SEC
      fi
      if [ "$TIME_NOW" -gt "$DIRECTION_CHANGE_TIME" ]; then
        echo "Changing Direction: $DIRECTION"
        DIRECTION=$(( DIRECTION * -1 ))
        DIRECTION_CHANGE_TIME=$(( $(date +%s) + $(_durationToSeconds ${PEAK_DURATION_SEC}) ))
      fi
    done
   ;;
 sleep)
   sleep 3600
   ;;
  *)
    echo "Command not recognized [$@]"
    ;;
esac
