# Grafana Private Data Soruce Connection (PDC) configuration example

Configures the [Grafana PDC](https://grafana.com/docs/grafana-cloud/data-configuration/configure-private-datasource-connect/) to connect to a local PostgreSQL database

## PostgreSQL Datasource configuration
```
Host: postgres-server:5432
Database: dvdrental
User: postgres / welcome1
TLS/SSL Mode: disable
Secure Socks Proxy Enable: True
```

## Usage

Requires Docker, docker-compose

Please see ctl.sh
 
