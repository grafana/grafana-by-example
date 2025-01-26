#
# Apple002
export OTEL_EXPORTER_OTLP_PROTOCOL="http/protobuf"
export OTEL_EXPORTER_OTLP_ENDPOINT="https://otlp-gateway-<REQUIRED>.grafana.net/otlp"
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Basic <NOT_REQUIRED>"
export GRAFANA_CLOUD_OTLP_INSTANCE_ID="<REQUIRED>"
export GRAFANA_CLOUD_OTLP_PASSWORD="<REQUIRED>"
#
# Apple002
export PYROSCOPE_SERVER_ADDRESS="https://profiles-<REQUIRED>.grafana.net"
export PYROSCOPE_BASIC_AUTH_USER="<REQUIRED>"
export PYROSCOPE_BASIC_AUTH_PASSWORD="<REQUIRED>"
#
#
# Service name
export OTEL_SERVICE_NAME: rideshare.java.ryder
# Gafana Cloud Logs
export GRAFANA_CLOUD_LOGS_ENDPOINT="https://<REQUIRED>.grafana.net/loki/api/v1/push"
export GRAFANA_CLOUD_LOGS_ID="<REQUIRED>"
export GRAFANA_CLOUD_LOGS_PASSWORD="<REQUIRED>"
