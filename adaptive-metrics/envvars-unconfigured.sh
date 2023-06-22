# Grafana Metrics Endpoint
# See: https://grafana.com/docs/grafana-cloud/metrics-prometheus/
export GRAFANA_PROJECT_NAME="<project-name>"
export GRAFANA_METRICS_KEY_NAME="<Key Name>"
export GRAFANA_METRICS_HOST="<required, eq:>  prometheus-prod-10-prod-us-central-0.grafana.net"
export GRAFANA_METRICS_USERNAME="<required>"
export GRAFANA_METRICS_API_KEY="<required>"
export GRAFANA_METRICS_QUERY_URL="https://$GRAFANA_METRICS_HOST/api/prom/api/v1"
export GRAFANA_METRICS_WRITE_URL="https://$GRAFANA_METRICS_HOST/api/prom/push"
export GRAFANA_METRICS_ADAPTIVE_URL="https://$GRAFANA_METRICS_HOST"

