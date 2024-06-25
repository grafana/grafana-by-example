#!/bin/bash
#
#
# Author: David Ryder, David.Ryder@Grafana.com
#
# Requires jq
source helper-functions.sh

HTTP_SILENT="-s"
#HTTP_SILENT=""

_help() {
  echo "Command not recognized [$@]"
  echo "Help:"
  echo "  query      <stack> <search-term> - search all annotations"
  echo "  create     <stack> <dashboard uuid> <panel id> - create an annotation "
}

_configureForStack() {
  #echo "Configureing for stack: [$STACK_SLUG_NAME]"
  if [ -z "$STACK_SLUG_NAME" ]; then
    echo "Stack slug name missing: [], exiting"
    exit 0
  fi
  export API_KEY_NAME=$STACK_SLUG_NAME"_STACK_API_KEY"
  export API_KEY_FILE_NAME=$GRAFANA_INFO_DIR/$API_KEY_NAME".stackapikey"
  export GRAFANA_CLOUD_STACK_API_KEY=$(cat $API_KEY_FILE_NAME | jq -r '.key')
  if [ -z "$GRAFANA_CLOUD_STACK_HOST" ]; then
    export GRAFANA_CLOUD_STACK_HOST="$STACK_SLUG_NAME.grafana.net"
  fi
}

# API_KEY_FILE format
# {"id":<id-number>,"name":"_API_KEY_1","key":"<stack-api-key"}


_queryAnnotations() {
    STACK_SLUG_NAME=${1:-"SLUG_NOT_SET_ERROR"}
    SEARCH_TERM=${2:-"%"} # Query All
    #OUTPUT_TYPE=" | jq  -c '.[] | {title, uid}'"
    # Empty search "%" return all dashboards
    DATA="limit=100"
    _configureForStack
    curl $HTTP_SILENT -G "$GRAFANA_CLOUD_PROTOCOL://$GRAFANA_CLOUD_STACK_HOST/api/annotations"  \
            -H "Accept: application/json"          \
            -H "Content-Type: application/json"    \
            -H "Authorization: Bearer $GRAFANA_CLOUD_STACK_API_KEY" \
            -d "$DATA" $OUTPUT_TYPE
}

_createAnnotation() {
  STACK_SLUG_NAME=${1:-"SLUG_NOT_SET_ERROR"}
  DASHBOARD_UID=${2:-""}
  PANEL_ID=${3:-""}
  echo $STACK_SLUG_NAME $DASHBOARD_UID $PANEL_ID
  #_configureForStack
  START_TIME_OFFSET="5m"
  END_TIME_DURATION="2m"
  #DASHBOARD_UID="_99waNa7z"
  A_TAGS="[\"owner=davidryder\",\"state=test\"]"
  A_TEXT="TEST1_AUTO"
  START_TIME_NSEC=$(( $(date +%s) - $(_durationToSeconds ${START_TIME_OFFSET}) ))"000"
  END_TIME_NSEC=$(( $START_TIME_NSEC + $(_durationToSeconds ${END_TIME_DURATION}) ))
  DATA="{
            \"dashboardUID\": \"$DASHBOARD_UID\",
            \"panelId\": $PANEL_ID,
            \"time\": $START_TIME_NSEC,
            \"timeEnd\": $END_TIME_NSEC,
            \"tags\": $A_TAGS,
            \"text\": \"$A_TEXT\"
          }"
  echo $DATA

  curl $HTTP_SILENT -X POST "$GRAFANA_CLOUD_PROTOCOL://$GRAFANA_CLOUD_STACK_HOST/api/annotations"  \
            -H "Accept: application/json"          \
            -H "Content-Type: application/json"    \
            -H "Authorization: Bearer $GRAFANA_CLOUD_STACK_API_KEY" \
            -d "$DATA"
}

_getDashboardFromUid() {
    STACK_SLUG_NAME=${1:-"SLUG_NOT_SET_ERROR"}
    DASHBOARD_UID=${2:-"UID_NOT_SET_ERROR"}
    _configureForStack
    curl $HTTP_SILENT -X GET "$GRAFANA_CLOUD_PROTOCOL://$GRAFANA_CLOUD_STACK_HOST/api/dashboards/uid/$DASHBOARD_UID"  \
         -H "Accept: application/json"          \
         -H "Content-Type: application/json"    \
         -H "Authorization: Bearer $GRAFANA_CLOUD_STACK_API_KEY"
}

#echo $GRAFANA_CLOUD_HOST
#echo $GRAFANA_CLOUD_API_KEY

case "$1" in
    initialize)
    ;;
    query)
        STACK_SLUG_NAME=$2
        SEARCH_TERM=${3:-"%"}
        _queryAnnotations $STACK_SLUG_NAME $SEARCH_TERM
    ;;
    create)
        STACK_SLUG_NAME=$2
        DASHBOARD_UID=$3
        PANEL_ID=$4
        _createAnnotation $STACK_SLUG_NAME $DASHBOARD_UID $PANEL_ID
    ;;
  test)
    echo "test $@"
  ;;
  *)
    _help
  ;;
esac

exit 0
