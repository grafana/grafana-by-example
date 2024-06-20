# Grafana Agent vsphere integration configuration example

Configures the [Grafana Agent](https://grafana.com/docs/agent/latest/set-up/) vsphere integration against the vcenter-simulator using docker-compose for testing purposes

## Grafana Agent
The grafana Agent [vsphere_config](https://grafana.com/docs/agent/latest/configuration/integrations/integrations-next/vsphere-config/) block configures the vmware_exporter integration, an embedded version of vmware_exporter, configured to collect vSphere metrics

## Grafana Alloy
This example now includes the use of [Grafana Alloy](https://grafana.com/docs/alloy/latest/#grafana-alloy) and the [otelcol.receiver.vcenter](https://grafana.com/docs/alloy/latest/reference/components/otelcol.receiver.vcenter/#otelcolreceivervcenter) as the default configuration to accept metrics from a vCenter or ESXi host running VMware vSphere APIs and forward them to other otelcol.* components

## Usage

Requires Docker, docker-compose, and Linux envsubst and jq
 
### Environment Varibles
Configure the environment variables below from your Grafana Cloud Account:

1. Log into your [Grafana Cloud account](https://grafana.com/auth/sign-in) to access the Cloud Portal
2. Edit the file: ```envvars-grafana-cloud-unconfigured.sh```
3. Configure the _USERNAME, _API_KEY and _HOST environment variables from the Metrics section of Grafana Cloud. Optionally the Logs and Traces environment variables can be configured.

## Configure
```
source envvars-grafana-cloud-unconfigured.s
./ctl.sh configure
```
The above generates the Grafana Agent configuration file and the docker-compose.yaml file in the directory ```./configure``` These configuration files can be edited manually if required.

## Start the containers using Docker Compose
```
./ctl.sh up
```
## Validate Metrics
Validate vsphere metrics are being produced into Grafana Cloud metrics. Using the [Explore](https://grafana.com/docs/grafana/latest/explore/) feature you should see metrics smilar to:
*   vsphere_HostSystem_cpu_totalCapacity_average
*   vsphere_HostSystem_cpu_usage_average
*   vsphere_Datacenter_vmop_numPoweron_latest

An example dashboard is available by importing ```dashboard-vsphere-1.json``` into Grafana

## Stop the containers using Docker Compose
```
./ctl.sh down
```

## Reference Blogs
Content was derived from the following blogs with thanks to the respective authors:

* [Testing vCenter Simulator in Docker Playground](https://vcloudvision.com/2019/01/02/testing-vcenter-simulator-in-docker-playground)

* [vCenter Simulator Docker Container](https://brianbunke.com/blog/2018/12/31/vcenter-simulator-ci/)

* [Dockerhub vCenter and ESi API based simulator](https://hub.docker.com/r/nimmis/vcsim)

* [vSphere Web Services SDK Clients](https://docs.vmware.com/en/VMware-Cloud-on-AWS/services/vmc-aws-performance/GUID-02CB4E53-2039-4ED7-BAB0-CFE30FB1C6F0.html)