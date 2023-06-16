## Prometheus Metrics Generator

Implements a Prometheus metrics generator client paired with a Grafana Agent to scrape and remote write the metrics to Grafana Cloud Metrics

### Requirements
- Requires docker-compose

### Usage
```./metrics-generator regions <metric-prefix> <regions> <services> <hosts> <duration-minutes> <rate-per-minute> <report-interval-sec>```

### Start the containers using Docker Compose
```./ctl.sh start```

### Stop the local containers
```./ctl.sh stop```

