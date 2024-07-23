# Grafana Enterprise and Splunk Enterprise

Provides a docker-compose deployment for Grafana Enterprise and Splunk Enterprise allowing for the demonstration of the [Grafana Splunk Datasource Plugin](https://grafana.com/grafana/plugins/grafana-splunk-datasource/)

A Grafana Enterprise License is required to test the Grafana Enterprise Plugins, available here: [Grafana Enterprise Trial](https://grafana.com/signup/grafana-enterprise/trial/connect-account)

# Clone this repository
```
git clone https://github.com/grafana/grafana-by-example-configuration.git
cd splunk
```
Copy a valid Grafana Enterprise license to the file ge-license.jwt. For example:
```
cp ~/Downloads/license.jwt ge-license.jwt
```


## Start the containers
```
docker-compose up
```

## Test Splunk Enterprise is acessible using:
```
curl -k -u admin:welcome1 "https://localhost:8089/services/server/info?output_mode=json"
curl -k -u admin:welcome1 "https://splunk-enterprise:8089/services/server/info?output_mode=json"
```
## Login to Splunk Enterprise
Login to the local [Splunk Enterpise](http://localhost:8000/) using (admin/welcome1) and create a new Token for the admin user

## Login to the Local Grafana instance
Access the local Grafana instance at [http://localhost:3000](http://localhost:3000)

Configure a Splunk Datasource: [Connections](http://localhost:3000/connections/datasources) using the following parameters:
- URL: https://splunk-enterprise:8089
- Authentication: Alternative authentication
- Authentication token: Use the token generated from previous step
- Skip TLS certificate validation: True

Save and Test, the data source should now be connected to the local Splunk instance

## Explore the Splunk data
Using Grafana [Explore](http://localhost:3000/explore) explore the data in Splunk using the Splunk Query language. For example:

Show all Splunk indexes:
```
| eventcount summarize=false index=* | dedup index | fields index
```

Query internal data:
```
| from datamodel:"internal_server.server"
```

## Stop the containers
```
docker-compose down
```