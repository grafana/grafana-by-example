#!/bin/bash
#
# Author: David Ryder, David.Ryder@Grafana.com
#
#
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
_epochSecToHR() {
  EPOCH_TIME_SEC=$1
  echo $( date -j -f "%s" $EPOCH_TIME_SEC +"%Y %h %d %H:%M:%S" )
}
