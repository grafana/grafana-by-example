## Adaptive Metrics

[Documentation: Interact with Adaptive Metrics](https://grafana.com/docs/grafana-cloud/data-configuration/metrics/interact-with-adaptive-metrics/)

### Configure the required environment variables
source envvars-unconfigured.sh

### Show the top 20 recomendations
./am-demo.sh recommendations-show-top

### Choose a metric: eg: `pilot_proxy_convergence_time_bucket`

```
METRIC_NAME="pilot_proxy_convergence_time_bucket"
RULES_FILE="admin-rules-all.json"
```

### Use the helper script am-demo.sh

The helper script ```am-demo.sh``` will create a project directory using the value specified by the environment variable ```GRAFANA_PROJECT_NAME``` to store temporay files, the current set of applied rules, and individual rules

### Pull the current set of aggregation rules
```./am-demo.sh recommendations-create-all > $RULES_FILE```

### Get the recommendation rule for the metric
```./am-demo.sh aggregations-get-rule-metric $METRIC_NAME```

### Add the metric to the aggregation rules file
```./am-demo.sh aggregations-add-metric $METRIC_NAME $RULES_FILE```

### Apply the updated rules file
```./am-demo.sh aggregations-rules-post $RULES_FILE```

### Validate the metric is being aggregated using Cardinality Analysis Dashboards, this takes about 5 minutes to populate
```./am-demo.sh metric-labels $METRIC_NAME```

