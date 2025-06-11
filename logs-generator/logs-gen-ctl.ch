#!/bin/bash
#
#

# Example Log Lines
TEST1_LOG_LINE='YYYY MMM DD HH:MM:SS |app=APPLICATION_NAME|domain=local_host|sequence=SEQ_NUMBER|uuid=15F8E71E-A469-42C0-A9FC-45AF19439260|segment=SEGMENT_N|seq=SEQ_N|msg=MESSAGE_1'
JSON_LOG_LINE_1='{"http_code":"200","http_method":"GET","http_route":"/viewtest1view","level":"info","memory_usage":44444,"msg":"","response_time":0.9263,"server_hostname":"node1","server_pid":123,"service_time":"1719267518216383068","time":"2024-06-24T22:18:38Z"}'
JSON_LOG_LINE_2='variable text - <code> 400 - {"http_code":"200","http_method":"GET","http_route":"/view1test1view1"} variable text'

# Set the log line here
TEST_LOG_LINE=$TEST1_LOG_LINE
TEST_LOG_LINE=$JSON_LOG_LINE_1

# Example LogQL regex to extract field values
# expression ="^.+\\|app=(?P<app_extracted>.*?)\\|.*\\|segment=(?P<segment_extracted>.*?)\\|.*$"
# {job="test1"} | pattern "<_>{<json_extracted>}<_>" | line_format " { {{.json_extracted}} }" | json | line_format "http_code: {{.http_code}}"


_replace_word() {
    LOG_LINE=$1
    SRC_WORD=$2
    TGT_WORD=$3
    echo $LOG_LINE | sed -r  "s/$SRC_WORD/$TGT_WORD/g"
}
_randomizeLogLine() {
    LOG_LINE=$1
    SRC_WORD=$2
    WORD_LIST=($3)
    WORD_LIST_LEN=${#WORD_LIST[@]}
    RND_N=$(( RANDOM % WORD_LIST_LEN ))
    TGT_WORD="${WORD_LIST[RND_N]}"
    echo $(_replace_word "$LOG_LINE" "$SRC_WORD" "$TGT_WORD")
}

_lokiPost() {
  LOKI_URL=${GRAFANA_LOGS_WRITE_URL/\/\////$GRAFANA_LOGS_USERNAME:$GRAFANA_LOGS_API_KEY@}""
  LABELS=$1
  MSG_STR=$2
  NOW_NS=$( date +%s%N );
  if [[ $NOW_NS == *"N"* ]]; then
    NOW_NS=$( date   +%s000000000 ); # macos
  fi
  echo $LOKI_URL $NOW_NS
  curl -H "Content-Type: application/json"  \
        -X POST """$LOKI_URL""" \
        -d "{\"streams\": [ { \"stream\": { $LABELS }, \"values\": [ [ \"$NOW_NS\", \"$MSG_STR\" ] ] } ] } "
}

# {"streams":[{"stream": { "job":"test1" }, "values": [ [ "1723925016000000000", "v1=100" ]]}]}



LIST_1="Application_1 Application_2 Application_3"
LIST_2="Segment_1 Segment_2 Segment_3"
LIST_3="1.05 2.16 3.41 9.12 10.1 10.2 10.3"
OUTPUT_FILE=output.log
rm $OUTPUT_FILE
touch $OUTPUT_FILE

CMD=${1:-"help"}
case "$CMD" in
    run)
        MAX_LOG_LINES=${2:-"10"}
        LOG_INTERVAL_SEC=${3:-"5"}
        N=0
        while [ $N -lt $MAX_LOG_LINES ]
        do
            TS=$(date '+%Y %b %d %H:%M:%S');
            L1=$(_replace_word "$TEST_LOG_LINE" "YYYY MMM DD HH:MM:SS" "$TS")
            L1=$( _randomizeLogLine "$L1" "APPLICATION_NAME" "$LIST_1" )
            L1=$( _randomizeLogLine "$L1" "SEGMENT_N" "$LIST_2" )
            L1=$( _randomizeLogLine "$L1" "0.9263" "$LIST_3" )
            L1=$( _replace_word "$L1" "SEQ_NUMBER" "$N" )
            echo $L1
            echo $L1 >> $OUTPUT_FILE
            sleep $LOG_INTERVAL_SEC
            N=$(( N + 1 ))
        done
        ;;
    run-json-object_1)
        JSON_OBJECT_FILE="json-object-1.json"
        TEST_LOG_LINE=$(cat $JSON_OBJECT_FILE)
        MAX_LOG_LINES=${2:-"10"}
        LOG_INTERVAL_SEC=${3:-"5"}
        N=0
        while [ $N -lt $MAX_LOG_LINES ]
        do
            L1=$(_replace_word "$TEST_LOG_LINE" "YYYY MMM DD HH:MM:SS" "$TS")
            #L1=$(date)
            echo $L1 >> $OUTPUT_FILE
            sleep $LOG_INTERVAL_SEC
            echo $N
            echo $L1
            N=$(( N + 1 ))
        done
    ;;
    start-alloy-arm64)
        ./alloy-darwin-arm64 run grafana-alloy-logs.river
    ;;
    post-local)
        LOKI_PORT=${2:-"3100"}
        JOB="status"
        HOST_NAME=$HOSTNAME
        export GRAFANA_LOGS_PROTOCOL="http"
        export GRAFANA_LOGS_HOST="grafana1.local:$LOKI_PORT"
        export GRAFANA_LOGS_USERNAME=""
        export GRAFANA_LOGS_API_KEY=""
        export GRAFANA_LOGS_QUERY_URL="$GRAFANA_LOGS_PROTOCOL//$GRAFANA_LOGS_HOST/loki/api/v1"
        export GRAFANA_LOGS_WRITE_URL="$GRAFANA_LOGS_PROTOCOL://$GRAFANA_LOGS_HOST/loki/api/v1/push"
        _lokiPost "\"job\": \"$JOB\", \"hostname\": \"$HOST_NAME\"" "{\\\"v1\\\":$(( RANDOM % 10 )) , \\\"v2\\\":$(( RANDOM % 10 )) }"
    ;;
    post-remote)
        JOB="status"
        HOST_NAME=$HOSTNAME
        _lokiPost "\"job\": \"$JOB\", \"hostname\": \"$HOST_NAME\"" "{\\\"v1\\\":$(( RANDOM % 10 )) , \\\"v2\\\":$(( RANDOM % 10 )), \\\"v3\\\":\\\"test1test2test3\\\" }"
    ;;
    gen-test-data)
        NOW_NS=$( date +%s%N );
        if [[ $NOW_NS == *"N"* ]]; then
            NOW_NS=$( date +%s%0000000000 ); # macos
        fi
        LABELS="\"job\": \"$JOB\""
        MSG_STR="v1=$(( RANDOM % 10 )) v2=$(( RANDOM % 10 ))"
        echo "{\"streams\": [ { \"stream\": { $LABELS }, \"values\": [ [ \"$NOW_NS\", \"$MSG_STR\" ] ] } ] } "
    ;;
    *)
        echo "Command not recognized [$@]"
        echo "Help:"
        echo "  run [ <Number of Log Lines> ] [<Delay Internval Seconds]"
        echo "  start-alloy-darwin"
    ;;
esac
