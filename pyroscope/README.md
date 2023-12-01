## Grafana Pyroscope

This example Docker Compose deployment brings together Pyroscope, Mimir, Grafana Agent using Flow, the HotROD application and a sample Go application instrumented with pprof wrappers to produce profiles.

Please note that some of content in this repository has been sourced from the original Grafana Pyroscope [GitHub Project](https://github.com/grafana/pyroscope) which does contain extensive working examples for Pyroscope.

Please see the [Pyroscope Documentation](https://grafana.com/docs/pyroscope/latest/?pg=oss-pyroscope&plcmt=hero-btn-3) for further information.

### Starting the services
```docker-compose up```

### Navigation
Once the services are started navigate to the local Grafana instance at [Grafana](http://localhost:3000) and login using ```admin/welcome1```

The folder Grafana ```Pyroscope``` contains a ```Navigation``` dashboard and a ```Pyroscope Usage``` dashboard which shows the volume of data ingested into the Pyroscope TSDB

### Dynamically Change the Pyroscope scrape interval
The Grafana Agent in [Flow](https://grafana.com/docs/agent/latest/flow/) mode is used to scrape profiles from the test Go application, the scrape interval is dependent on the contents of the file [dynamic.json](https://github.com/grafana/grafana-by-example-configuration/blob/main/pyroscope/grafana-agent/dynamic.json) and can be changed dynamically at run time by modifying the contents of this file.

### Stopping the services
```docker-compose down```

