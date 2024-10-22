 # Grafana Cloud Usage Metrics

 Use the data source: `grafanacloud-usage`
 

## Usage metrics
- Review the following useage metrics in the grafanacloud-usage data source 
- These will be used for the dashboarrd build
```
grafanacloud_org_metrics_billable_series{}
grafanacloud_org_metrics_overage{} 
grafanacloud_org_metrics_included_dpm_per_series{}
grafanacloud_org_spend_commit_credit_total{}
grafanacloud_org_spend_commit_balance_total{} 
grafanacloud_org_total_overage{} 
grafanacloud_instance_billable_usage{}
grafanacloud_instance_samples_per_second{}
grafanacloud_instance_info{}
```

## Getting Started
- A Grafana Cloud account is required for this project, a Grafana Cloud Free tier account may be used
- To get started create a new dashboard in the Grafana instance and name it `cost-management`
- 

## Queries

- Add the following set of queries, using cut and paste, to a Grafana Dashboard to start the cost management dashboard build process
- Utilize the layout described in the Conceptual Dashboard design

![Conceptual Dashboard design](https://github.com/grafana/grafana-by-example/blob/main/cost-management/conceptual-dashboard-design.png)

### Usage Metrics for the Organization
- Add these queries as individual Time Series panels
- Use the data source: `grafanacloud-usage` for all panels

#### Billable series metrics count for the Organization
- Duplicate this panel as a way to add the rest of the Time Series panels
```
# Title: Total Billable Series
# Panel: Stat
grafanacloud_org_metrics_billable_series{ }
```

#### Billable Series Cost for the Organization
```
# Title: Total Billable Series Cost
# Panel: Stat
sum( grafanacloud_org_metrics_overage{} )
```

#### Calculate the percentage change across the time range for the Organization
```
# Title: Change %
# Panel: Stat
delta( grafanacloud_org_metrics_billable_series{ } [ $__range ] )
/ grafanacloud_org_metrics_billable_series{ } @end()
```

#### Cost impact of change in Billable Series for the Organization
```
# Title: Cost Impact
# Panel: Stat
sum( grafanacloud_org_metrics_billable_series{} @end() 
     - grafanacloud_org_metrics_billable_series{} @start() )
/ sum( grafanacloud_org_metrics_billable_series{} )
* sum( grafanacloud_org_metrics_overage{} )
```

#### Calculate the change across the time range for the Organization
```
# Title: Change
# Panel: Stat
delta( grafanacloud_org_metrics_billable_series{ } [ $__range ] )
```

#### Optional, Add the series start and end values to the above panel
```
# Title: Start
# Panel: Stat
sum( grafanacloud_org_metrics_billable_series{ } @start() )
# End
sum( grafanacloud_org_metrics_billable_series{ } @end() )
```

#### Total Billable Series - create a second instance of this panel
```
# Title: Total Billable Series
# Panel: Time Series
grafanacloud_org_metrics_billable_series{ }
```

#### Selected Billable Series instance
```
# Filter using a dashboard variable: $VAR_ENV the instance billable usage
# Title: Total Billable Series, Environment: $VAR_ENV
# Panel: Time Series
sum by ( name ) (
    grafanacloud_instance_billable_usage{}
    * on (id) group_left( name ) grafanacloud_instance_info{ name=~"$VAR_ENV"   } )
```


### Usage Metrics for each Environment (instance) in the Organization
- Add all of these queries to a `Table panel` using the query format option: `Table`
- Use a Join by field Transformation to join them by the field name
- Use an Organize fields by name Transformation to hide the time and id columns, and rename the column headers
- Notice that for the purpose of this example we are filtering these queries using: name=~".*-prom" 

#### Calculate the Billable Series Count for each environment
```
# Title: Count
# Type: Instant
sort_desc(
 sum by ( name ) (
   grafanacloud_instance_billable_usage{}
   * on (id) group_left( name ) grafanacloud_instance_info{ name=~".*-prom" } ) )
 ```
#### Calculate the Series Cost for each environment: (I / O) * OC
```
# Title: Cost
# Type: Instant
sort_desc( ( 
  ( max( grafanacloud_instance_billable_usage{} ) by (id) ) # Stacks' Billable Series
    / ignoring(id) group_left() max( grafanacloud_org_metrics_billable_series{} ) by (id) ) # Divided by Org Billable Series
  * on (id) group_left(name) max by(id, name) (grafanacloud_instance_info{ name=~".*-prom" }) # Include only these
) * on () group_left() sum (grafanacloud_org_metrics_overage{} ) # Org-wide Metrics bil in USD
```

#### Billable Series Change % for each individual environment
```
# Title: Change %
# Type: Range
sort_desc(
 sum by ( name ) (
     ((grafanacloud_instance_billable_usage{} @end()) - grafanacloud_instance_billable_usage{} @start())
       / grafanacloud_instance_billable_usage{} @end()
       * on (id) group_left( name ) grafanacloud_instance_info{ name=~".*-prom" } ) )
```

#### Cost impact to individual environment of change in active series
```
# Title: Cost Impact
# Type: Range
sort_desc(
 sum by ( name ) (
    (( grafanacloud_instance_billable_usage{} @end()) - grafanacloud_instance_billable_usage{} @start())
       / on (org_id) group_left( name ) grafanacloud_org_metrics_billable_series{}
       * on (org_id) group_left( name ) grafanacloud_org_metrics_overage{}
       * on (id) group_left( name ) grafanacloud_instance_info{ name=~".*-prom" } ))
```

#### Add a dashboard variable: VAR_ENV
```
Type: Query
Name: VAR_ENV
Label: Environment
Data source: grafanacloud-usage
Query type: Label values
Label: name
Metric: grafanacloud-instance-info
Label filters: Optionally add a filter: name =~ .*-prom
```

#### Add data link to the table panel
- Add a Data Link to the table panel
- Copy the first part of the dashboard URL. It will look similar to the following:
- `https://<DOMAIN_NAME>/d/<DASHBOARD_UID>/<DASHBOARD_NAME>?`
- Append to the end: var-VAR_ENV=${__data.fields.Environment}
- The full Data Link URL should now look like this:
- `https://<DOMAIN_NAME>/d/<DASHBOARD_UID>/<DASHBOARD_NAME>?var-VAR_ENV=${__data.fields.Environment}`
- Save the Data Link
- Save the Dashboard
- Exit Edit
- Note the Data link depends on the Table column being named `Environment` and the previously created Dashboard variable `VAR_ENV`

## Dashboard Build Intermediate State

- Ideally at this stage of the dashboard build process the dashboard you have built looks similar to the following:

![Dashboard Stage 1](https://github.com/grafana/grafana-by-example/blob/main/cost-management/dashboard-stage-1.png)

- Clicking on a row in the Tabel will select which environment to show in the right hand side time series panel