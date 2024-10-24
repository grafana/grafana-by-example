 # Building a cost management dashboard in Grafana Cloud
- This is the participant workbook instructions for building a cost management dashboard for metrics usage
- The same concepts could be applied to other telemetry data types including: logs, traces and profiles
 

## Grafana Cloud Usage Metrics
- Review the following usage metrics using `grafanacloud-usage` data source in Grafana Cloud
- These will be used for the dashboard build
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
# Will be used to create the forecast and alerts
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

#### Add a data link to the table panel
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

## Dashboard Build - Stage 1

- Ideally at this stage of the dashboard build process the dashboard you have built looks similar to the following:

![Dashboard Stage 1](https://github.com/grafana/grafana-by-example/blob/main/cost-management/dashboard-stage-1.png)

- Clicking on a row in the Table will select which environment to show in the right hand side time series panel

## Next Steps
- Add a machine learning forecast job for the Total Billable Series metric
- Add alerting rules based on a threshold value, anomaly detection and forecasted values of the Total Billable Series metric
- Add an Alert panel to the dashboard to show triggered alerts
- Configure the units for each panel setting the units to either Misc / Short or Currency / Dollars ($) or Percentage (0.0-1.0) depending on their type. The Table panel will require the use of Field Override for each column to set the unit to the required type. This relatively straight forward set of changes to the dashboard and can be done after this webinar

#### Create a machine learning forecast job
- Create machine learning forecast job from the time series panel: Total Billable Series -> Panel Options -> Extensions ->  Create Forecast
- This will create a new metric forecast from the metric: `grafanacloud_org_metrics_billable_series{ }`
- Save the forecast using the name: cost_mgt_billable_series
- This will create a new set of metrics representing the forecasted time series and the upper and lower confidence bounds
- The job will take about 1-2 minutes to configure since its is evaluating historical data
- Click into this new metric forecast job and use the Copy as panel to copy this panel
- Navigate back to the cost management dashboard and then Edit -> Add -> Paste panel
- Modify the Query options of this panel to show 2 weeks of data with 3 days into the future
  ```
  Relative time: 2w
  Time shift: 0d/d+3d
  ```
- Add an additional third query to this panel:
  ```
  cost_mgt_billable_series:anomalous
  ```
-  The results of this query oscillate between -1 and 1 indicating when the time series is outside of the predicted upper and lower limits. Since the value range is between -1 an 1 configure an override to place the axis for this query on the right hand side of the panel so that it does not conflict with the billable series range
- The following metrics generated from this forecast job:
  ```
  cost_mgt_billable_series_1:predicted 
  cost_mgt_billable_series_1:anomalous
  cost_mgt_billable_series_1:actual
  ```

### Alerting
- Configure three types of alerts on the grafanacloud_org_metrics_billable_series{ } metric: 
  - Threshold based on a static value using the Total Billable Series (time series) panel
  - Anomaly based on forecasted upper and lower limits
  - Future threshold based on predicted future forecast value 2 weeks into the future


#### Threshold based alert
- Create a threshold based alert from the time series panel: Total Billable Series -> Panel Options -> More -> New Alert Rule
- Configure an appropriate threshold value based on your actual billable series
- Add a label to the alert: `costmgt = metrics ` allowing filtering for this alert in our dashboard and in notification policies
- Create an evaluation group `CostMgt5m` with the interval `5m`

#### Anomaly based alert
- Configure an anomaly based alert using the forecasted metrics panel: Panel Options -> More -> New Alert Rule
- Use only the metric tagged `anomalous` in the alert rule, delete the other metrics listed
  ```
  cost-mgt-billable-series:anomalous
  ```
- Configure the alert options
  ```
  Threshold
  IS OUTSIDE RANGE: -0.5 to 0.5
  Evaluation group and interval: 1h
  Labels: costmgt = metrics
  Contact point: Email
  ```

#### Future threshold based alert
- Configure future threshold based on predicted future forecast value 2 weeks into the future
 using the forecasted metrics panel: Panel Options -> More -> New Alert Rule
- Using only the metric tagged `predicted` in the alert rule, delete the other metrics listed
  ```
  cost-mgt-billable-series:predicted{ ml_forecast = "yhat" } offset -2w
  ```
- Configure the alert options
  ```
  Threshold: 
  IS ABOVE: <choose an appropriate threshold>
  Evaluation group and interval: costMgt5m
  Pending period: 5m
  Labels: costmgt = metrics
  Contact point: Email
  ```

#### Add an alert panel to the dashboard to show triggered alerts
- An an Alert list panel to the dashboard:
```
Title: Billing Alerts
Alert instance label: {costmgt="metrics"}
```

## Dashboard Build - Stage 2
- Ideally at this stage of the dashboard build process the dashboard you have built looks similar to the following:

![Dashboard Stage 1](https://github.com/grafana/grafana-by-example/blob/main/cost-management/dashboard-stage-2.png)

- A fully build out version of this dashboard is available for importing into your Grafana Cloud instance is available here: [dashboard-final.json](https://github.com/grafana/grafana-by-example/blob/main/cost-management/dashboard-final.png)
- The machine learning forecast job and the alerts will need to be created as described above

## Next Steps
- Your cost management dashboard for metrics is complete
- Grafana dashboards provide for a highly customizable and interactive experience to explore your Grafana Cloud usage data and many other types of observability data
- Thank you for participating in this project
- Please reach out to Grafana Labs to provide comments and feedback

### End

