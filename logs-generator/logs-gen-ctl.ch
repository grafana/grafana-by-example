#!/bin/bash
#
#

# Example Log Lines
TEST_LOG_LINE='YYYY MMM DD HH:MM:SS |app=APPLICATION_NAME|domain=local_host|sequence=SEQ_NUMBER|uuid=15F8E71E-A469-42C0-A9FC-45AF19439260|segment=SEGMENT_N|msg=MESSAGE_1'

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
            L2=$( _randomizeLogLine "$L1" "APPLICATION_NAME" "$LIST_1" )
            L3=$( _randomizeLogLine "$L2" "SEGMENT_N" "$LIST_2" )
            L4=$( _replace_word "$L3" "SEQ_NUMBER" "$N" )
            echo $L4
            echo $L4 >> $OUTPUT_FILE
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