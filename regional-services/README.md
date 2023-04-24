## Grafana Prometheus Client Examples

Provides a Grafana stack including: Grafana Server, Mimir, Grafana Agent and a Python Prometheus Client metrics generator

[Documentation: Promtheus Python Client ](https://github.com/prometheus/client_python)


### Requirements
Requires docker-compose

### Build the environment
```./ctl.sh build```

### Start the containers using Docker Compose
```./ctl.sh local up```

### Access the local Grafana instance
Browse to the local: [Grafana instance](http://localhost:3000) and login using ```admin/welcome1```

Review the dashboards in the folder [Regional Services](http://localhost:3000/d/b913ad8v/regional-services-2?orgId=1&refresh=10s) and the supporting mertrics

Browse to the local [Metrics Generator HTTP server](http://localhost:8001/) to see the raw Promtheus metrics being generated. The Grafana Agent is [configured](https://github.com/grafana/grafana-by-example-configuration/blob/main/regional-services/grafana-agent/config.yaml) to scrape these and remote write them, to the Mimi instance

### Stop the local containers
```./ctl.sh local down```

