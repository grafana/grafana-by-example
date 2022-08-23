# grafana-by-example-configuration
Grafana Configuration Examples

Requires Docker and Docker Compose

## Configure the environment variables

Configure the environment variables below from your Grafana Cloud Account:

1. Log into your [Grafana Cloud account](https://grafana.com/auth/sign-in) to access the Cloud Portal
2. Edit the file: ```envvars-grafana-cloud-unconfigured.sh```
3. Configure the _USERNAME, _API_KEY and _HOST environment variables from Metrics, Logs and Traces

## Configure
```
source envvars-grafana-cloud-unconfigured.s
./ctl.sh configure
```
## Start the containers using Docker Compose
```
./ctl.sh up
```

## Generate Traces
Browser to: http://127.0.0.1:8080/

## Explore Grafana Cloud Traces
Browser to your Grafana Cloud account and explore traces from the tempo datasource

