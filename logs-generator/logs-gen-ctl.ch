#!/bin/bash
#
#

# Example Log Lines
TEST1_LOG_LINE='YYYY MMM DD HH:MM:SS |app=APPLICATION_NAME|domain=local_host|sequence=SEQ_NUMBER|uuid=15F8E71E-A469-42C0-A9FC-45AF19439260|segment=SEGMENT_N|seq=SEQ_N|msg=MESSAGE_1'
JSON_LOG_LINE='{"http_code":"200","http_method":"GET","http_route":"/view","level":"info","memory_usage":44444,"msg":"","response_time":0.9263,"server_hostname":"node1","server_pid":123,"service_time":"1719267518216383068","time":"2024-06-24T22:18:38Z"}'

TEST_LOG_LINE=$JSON_LOG_LINE

# Example LogQL regex to extract field values
# expression ="^.+\\|app=(?P<app_extracted>.*?)\\|.*\\|segment=(?P<segment_extracted>.*?)\\|.*$"

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
    start-alloy-darwin)
        ./alloy-darwin-amd64 run grafana-alloy-logs.river
    ;;
    *)
        echo "Command not recognized [$@]"
        echo "Help:"
        echo "  run [ <Number of Log Lines> ] [<Delay Internval Seconds]"
        echo "  start-alloy-darwin"
    ;;
esac