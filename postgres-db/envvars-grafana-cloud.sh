# Grafana Cloud Configuration

# Loki Remote Write Endpoint
# See: https://grafana.com/docs/loki/latest/api/
export GRAFANA_LOGS_HOST="REQUIRED"
export GRAFANA_LOGS_USERNAME="REQUIRED"
export GRAFANA_LOGS_API_KEY="REQUIRED."
export GRAFANA_LOGS_QUERY_URL="https://$GRAFANA_LOGS_HOST/loki/api/v1"
export GRAFANA_LOGS_WRITE_URL="https://$GRAFANA_LOGS_HOST/loki/api/v1/push"

# Prometheus Remote Write Endpoint
# See: https://grafana.com/docs/grafana-cloud/metrics-prometheus/
export GRAFANA_METRICS_HOST="REQUIRED"
export GRAFANA_METRICS_USERNAME="REQUIRED"
export GRAFANA_METRICS_API_KEY="REQUIRED"
export GRAFANA_METRICS_QUERY_URL="https://$GRAFANA_METRICS_HOST/api/prom/api/v1"
export GRAFANA_METRICS_WRITE_URL="https://$GRAFANA_METRICS_HOST/api/prom/push"
