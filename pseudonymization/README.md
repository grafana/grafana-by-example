# Grafana - ​​Anonymizing Data in Logs

Provides a working example using Grafana Alloy and the OpenTelemetry collector that anonymizes sensitive data in logs. A hash function is used on select fields to anonymize them. The anonymized logs are routed to a production logging instance, and the original data and hash are routed to a sensitive data store.

## Architecture
![Architecture](https://github.com/grafana/grafana-by-example-configuration/blob/main/pseudonymization/diagram1.png)
