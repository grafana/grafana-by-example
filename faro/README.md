## Grafana Faro

[Documentation: Grafana Faro Web SDK](https://grafana.com/docs/grafana-cloud/faro-web-sdk/)

### Configure the required environment variables

Requires the environment variable ```GRAFANA_FARO_APP_KEY``` to be set to the Grafana Cloud Observability Application

```source envvars-empty.sh```

### Configure the environment
```./ctl.sh configure```

### Start the containers using Docker Compose
```./ctl.sh local up```

### Access the local Grafana instance
Browser to the local: [Grafana instance](http://localhost:3000) and login using ```admin/welcome1```
Navigate around to generate Faro telememetry data

### Validate the Faro telemetry data
Navigate to the Grafana Cloud Observability Application to visualize the Faro telemetry data

### Stop the local containers
```./ctl.sh local down```

