#!/bin/bash
#
# Author: David Ryder, David.Ryder@Grafana.com
#
# Requires jq

# Set these
# export GRAFANA_METRICS_HOST="<REQUIRED>"
# export GRAFANA_METRICS_USERNAME="<REQUIRED>"
# export GRAFANA_METRICS_API_KEY="<REQUIRED>"
# export GRAFANA_METRICS_QUERY_URL="https://$GRAFANA_METRICS_HOST/api/prom/api/v1"
# export GRAFANA_METRICS_WRITE_URL="https://$GRAFANA_METRICS_HOST/api/prom/push"
# export GRAFANA_METRICS_ADAPTIVE_URL="https://$GRAFANA_METRICS_HOST"

_adaptiveMetricsURL() {
  API_PATH=$1
  echo ${GRAFANA_METRICS_ADAPTIVE_URL/\/\////$GRAFANA_METRICS_USERNAME:$GRAFANA_METRICS_API_KEY@}"$API_PATH"
}

_queryURL() {
  API_PATH=$1
  echo ${GRAFANA_METRICS_QUERY_URL/\/\////$GRAFANA_METRICS_USERNAME:$GRAFANA_METRICS_API_KEY@}"$API_PATH"
}

_labelValues() {
  LABEL_NAME=$1
  METRICS_URL=$(_queryURL "/label/$LABEL_NAME/values")
  curl  $HTTP_OPTIONS \
        -H "Content-Type: application/json"  \
        -X GET """$METRICS_URL"""
}

_metricLabels() {
  METRIC_NAME=$1
  METRICS_URL=$(_queryURL /labels)
  DATA1="match[]=$METRIC_NAME"
  DATA2="time=$NOW_SEC"
  curl  $HTTP_OPTIONS \
        -H "Content-Type: application/json"  \
        -G """$METRICS_URL""" \
        -d "$DATA1"
}

HTTP_OPTIONS="-s"
COLLISION_TMP_FILE="collision-tmp.txt" 
GRAFANA_PROJECT_DIR="project-$GRAFANA_PROJECT_NAME"
NEW_AGGREGATION_FILE="$GRAFANA_PROJECT_DIR/new-aggregation.json"
RECOMMENDATIONS_ALL_FILE="$GRAFANA_PROJECT_DIR/recommendations-all.json"
CURRENT_RULES_FILE="$GRAFANA_PROJECT_DIR/current-rules.json"
HTTP_HEADERS_FILE="$GRAFANA_PROJECT_DIR/headers.txt"
if [[ ! -e $GRAFANA_PROJECT_DIR ]]; then
    mkdir -p $GRAFANA_PROJECT_DIR
fi
case "$1" in
    get-config)
        METRICS_URL=$(_adaptiveMetricsURL "aggregations/recommendations/config")
        curl  $HTTP_OPTIONS \
                -H "Content-Type: application/json"  \
                -D $HTTP_HEADERS_FILE \
                -X GET """$METRICS_URL"""
    ;;
    recommendations-show-top)
      METRICS_URL=$(_adaptiveMetricsURL "/aggregations/recommendations")
      curl  $HTTP_OPTIONS \
            -H "Content-Type: application/json"  \
            -D $HTTP_HEADERS_FILE \
            -X GET """$METRICS_URL""" |
            jq -r '.[] | [ .metric ] | join(" ")' | head -n 20
    ;;
    recommendations-show-all)
      METRICS_URL=$(_adaptiveMetricsURL "/aggregations/recommendations")
      curl  $HTTP_OPTIONS \
            -H "Content-Type: application/json"  \
            -D $HTTP_HEADERS_FILE \
            -X GET """$METRICS_URL""" | jq
    ;;
    aggregations-get-rule-metric)
        METRIC_NAME=$2
        AGGREGATION_FILE="$GRAFANA_PROJECT_DIR/$METRIC_NAME.rule.json"
        METRICS_URL=$(_adaptiveMetricsURL "/aggregations/recommendations")
        curl  $HTTP_OPTIONS \
            -H "Content-Type: application/json"  \
            -D $HTTP_HEADERS_FILE \
            -X GET """$METRICS_URL""" |
            jq --arg METRIC_NAME $METRIC_NAME -r '.[] | select(.metric==$METRIC_NAME) | [.]' > $AGGREGATION_FILE
        echo "New Aggregation rules file: $AGGREGATION_FILE"
        cat $AGGREGATION_FILE
    ;;
    aggregations-add-metric)
        METRIC_NAME=$2
        RULES_FILE=${3:-"FILE_NONE.json"}
        PREVIOUS_RULES_FILE="$GRAFANA_PROJECT_DIR/$RULES_FILE.previous"
        AGGREGATION_FILE="$GRAFANA_PROJECT_DIR/$METRIC_NAME.rule.json"
        mv $RULES_FILE $PREVIOUS_RULES_FILE
        jq --slurpfile NEW_AGG $AGGREGATION_FILE '. + $NEW_AGG[]' $PREVIOUS_RULES_FILE > $RULES_FILE
    ;;
    aggregations-rules-post)
        HTTP_OPTIONS="-v"
        RULES_FILE=${2:-"FILE_NONE.json"}
        METRICS_URL=$(_adaptiveMetricsURL "/aggregations/rules")
        cat $HTTP_HEADERS_FILE | grep -i '^etag:' | sed 's/^ETag:/If-Match:/i' > "$COLLISION_TMP_FILE"
        curl  --header @"$COLLISION_TMP_FILE" \
                --data-binary @$RULES_FILE \
                $HTTP_OPTIONS \
                -H "Content-Type: application/json"  \
                -X POST """$METRICS_URL"""
    ;;
    aggregations-rules-get)
        METRICS_URL=$(_adaptiveMetricsURL "/aggregations/rules")
        curl -D $HTTP_HEADERS_FILE \
            $HTTP_OPTIONS \
            -H "Content-Type: application/json"  \
            -X GET """$METRICS_URL""" > $CURRENT_RULES_FILE
    echo "Created: $CURRENT_RULES_FILE"
    ;; 
    cli-recommendations-show-top)
        # Displays the top 10 
        # metric_name, total_before, total_after, reduction, reduction_%
        TOP_N=${2:-"10"}
        echo "Recommendations (first $TOP_N):"
        ./adaptive-cli.darwin.amd64 \
            --user $GRAFANA_METRICS_USERNAME \
            --url $GRAFANA_METRICS_ADAPTIVE_URL \
            --password $GRAFANA_METRICS_API_KEY \
            show recommendations --verbose > $RECOMMENDATIONS_ALL_FILE
        echo metric_name, total_before, total_after, reduction, reduction_%
        cat $RECOMMENDATIONS_ALL_FILE |
        jq -r '.[]
                | [ .metric, .total_series_before_aggregation, .total_series_after_aggregation,
                .total_series_before_aggregation - .total_series_after_aggregation,
                100 - (.total_series_after_aggregation / .total_series_before_aggregation * 100) ]
                | join(" ")' \
            | head -n $TOP_N
    ;;
    cli-recommendations-summary)
        TOTAL_METRICS_BEFORE=`jq -r '[.[] | .total_series_before_aggregation | tonumber] |  add'  $RECOMMENDATIONS_ALL_FILE`
        TOTAL_METRICS_AFTER=`jq -r '[.[] | .total_series_after_aggregation | tonumber] |  add'  $RECOMMENDATIONS_ALL_FILE`
        REDUCTION_PERCENTAGE=$(echo "scale=3; 1 - $TOTAL_METRICS_AFTER / $TOTAL_METRICS_BEFORE" | bc -l)
        echo "Before: $TOTAL_METRICS_BEFORE After: $TOTAL_METRICS_AFTER By %: $REDUCTION_PERCENTAGE"
    ;;
    cli-aggregations-get-rule-metric)
        # Get the recommendation rule for a specific metric
        METRIC_NAME=$2
        AGGREGATION_FILE="$GRAFANA_PROJECT_DIR/$METRIC_NAME.rule.json"
        cat $RECOMMENDATIONS_ALL_FILE |
            jq --arg METRIC_NAME $METRIC_NAME -r '.[] | select(.metric==$METRIC_NAME) | [.]' > $AGGREGATION_FILE
        echo "New Aggregation rules file: $AGGREGATION_FILE"
        cat $AGGREGATION_FILE
    ;;
    2)
        # create a rules file for specified metric
        METRIC_NAME=$2
        if [ "$METRIC_NAME" != "" ]; then
            ./adaptive-cli.darwin.amd64 \
                --user $GRAFANA_METRICS_USERNAME \
                --url $GRAFANA_METRICS_ADAPTIVE_URL \
                --password $GRAFANA_METRICS_API_KEY \
                show recommendations |
                jq --arg METRIC_NAME $METRIC_NAME -r '.new_rules[] | select(.metric==$METRIC_NAME) | [.]' > $NEW_AGGREGATION_FILE
            echo "New Aggregation rules file"
            cat $NEW_AGGREGATION_FILE
        else
            echo "Select a metric from the above list"
        fi
    ;;
    3)
        # Apply the rules file for single metric - no overwite
        echo "Applying Aggregation rules file: $NEW_AGGREGATION_FILE"
        ./adaptive-cli.darwin.amd64 \
            --user $GRAFANA_METRICS_USERNAME \
            --url $GRAFANA_METRICS_ADAPTIVE_URL \
            --password $GRAFANA_METRICS_API_KEY \
            create aggregations --filename $NEW_AGGREGATION_FILE
        # --overwrite 
    ;;
    4)
        # current rules reflect the existing rules you have in place.
        # current rules may be out of sync with the rules returned by show aggregations.
        echo "Current Rules"
        ./adaptive-cli.darwin.amd64 \
        --user $GRAFANA_METRICS_USERNAME \
        --url $GRAFANA_METRICS_ADAPTIVE_URL \
        --password $GRAFANA_METRICS_API_KEY \
        show recommendations | 
        jq -r '.current_rules[] | [ .metric ] | join(" ")' | head -n 10
    ;;
    metric-labels)
        # Get labels for a metric
        METRIC_NAME=$2
        _metricLabels $METRIC_NAME
    ;;
    test)
    echo "test $@"
    ;;
  *)
    _help
    ;;
esac

exit 0