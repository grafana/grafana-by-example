# Grafana Private Data Source Connection (PDC) configuration example

Configures the [Grafana PDC](https://grafana.com/docs/grafana-cloud/data-configuration/configure-private-datasource-connect/) to connect to a local PostgreSQL database

## Architecture
![Architecture](https://github.com/grafana/grafana-by-example-configuration/blob/main/private-data-source/images/Grafana-PDC-Architecture-1.png)

## PDC Environment Variables
A PDC must be configured first in Grafana Cloud. These environment variables are derived from the Grafana Cloud PDC Configuration Details

```
export GRAFANA_CLOUD_PDC_TOKEN=""
export GRAFANA_CLOUD_PDC_ID=""
export GRAFANA_CLOUD_PDC_CLUSTER=="
export GRAFANA_CLOUD_PDC_DOMAIN=""
```
## Requires
Requires Docker, docker-compose

## Start The Local Services

Download resources

`./ctl.sh download`

Build Containers

`./ctl.sh build`

Start the PostgreSQL database and the PDC agent:

`./ctl.sh start`

## PostgreSQL Datasource configuration
Once the PDC is configured a PostgreSQL Data Source should also be configured in Grafana Cloud to connect to the local PostgreSQL database
```
Host: postgres-server:5432

Database: dvdrental

User: postgres / welcome1

TLS/SSL Mode: disable

Secure Socks Proxy Enable: True
```

Select Save & Test to validate the PostgreSQL Data Source is working

Use Grafana Explore to explore the data in the PostgreSQL database


## Stop The Local Services
`./ctl.sh stop`

The Grafana Cloud PostgreSQL Data Source will now now longer be able to connect to the local database
