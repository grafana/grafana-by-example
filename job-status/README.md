# Grafana by Example: Job Services and Log Stream Processor

Provides an example log-stream processor that generates metrics and logs from a log stream. Useful for deriving metrics and logs from events with state transitions.

# Requirements
Requires Docker, Docker Compose and a Grafana Free Tier Cloud Account

## Configure the environment variables

Configure the environment variables below from your Grafana Cloud Account:

1. Log into your [Grafana Cloud account](https://grafana.com/auth/sign-in) to access the Cloud Portal
2. Edit the file: ```unconfigured-grafana-cloud.env```
3. Configure the _USERNAME, _API_KEY and _HOST environment variables from the Metrics and Logs sections of Grafana Cloud
4. Rename the file to ```grafana-cloud.env.```

## Configure and Build
```
source envvars-grafana-cloud-unconfigured.s
./ctl.sh configure
./ctl.sh build
```
## Start the containers using Docker Compose
```
./ctl.sh up
```

## Explore Grafana Cloud Metrics and Logs
Browse to your Grafana Cloud account and explore logs and metrics being generated

Import the dashboard [job-status-dashboard-1.json](https://github.com/grafana/grafana-by-example-configuration/blob/main/job-status/grafana-server/job-status-dashboard-1.json) to visualize this data

## Stop the containers
```
./ctl.sh down
```