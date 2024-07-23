# Grafana Enterprise and Splunk Enterprise

Provides a docker-compose deployment for Grafana Enterprise and Splunk Enterprsie allow for the demonstration of the [Grafana Splunk Datasource Plugin](https://grafana.com/grafana/plugins/grafana-splunk-datasource/)

## Test Splunk Enterprise is acessible using:
```
curl -k -u admin:welcome1 "https://localhost:8089/services/server/info?output_mode=json"
curl -k -u admin:welcome1 "https://splunk-enterprise:8089/services/server/info?output_mode=json"
```



# Get all indexes

| eventcount summarize=false index=* | dedup index | fields index

| from datamodel:"internal_server.server"
