## Prometheus Metrics Generator

Implements a Prometheus metrics generator client paired with a Grafana Agent to scrape and remote write the metrics to Grafana Cloud Metrics

### Requirements
- Requires docker-compose

### Usage

Configure the environment variables for the Grafana Cloud instance in the file: ```unconfigured-grafana-cloud.env ```

### Configure the environment
```
source unconfigured-grafana-cloud.env
./ctl.sh configure
```

### Start the containers using Docker Compose
```
./ctl.sh start
```

### Validate the Promtheues metrics are being produced

The metrics ```test1_service_status``` and ```test2_service_status``` should be visible in the Grafana Cloud instance

### Stop the local containers
```
./ctl.sh stop
```

