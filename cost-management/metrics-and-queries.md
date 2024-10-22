 # Grafana Cloud Usage Metrics

 Use the data source: `grafanacloud-usage`
 

## Usage metrics
```
grafanacloud_org_metrics_billable_series{}
grafanacloud_org_metrics_overage{} 
grafanacloud_org_metrics_included_dpm_per_series{}
grafanacloud_org_spend_commit_credit_total{}
grafanacloud_org_spend_commit_balance_total{} 
grafanacloud_org_total_overage{} 
grafanacloud_instance_billable_usage{} > 0
grafanacloud_instance_samples_per_second{}
grafanacloud_instance_info{}
```
## Queries

### Billable series metrics count
```
grafanacloud_org_metrics_billable_series{ }
```

### Billable Series Cost
```
sum( grafanacloud_org_metrics_overage{} )
```

### Calculate the percentage change across the time range
```
delta( grafanacloud_org_metrics_billable_series{ } [ $__range ] )
/ grafanacloud_org_metrics_billable_series{ } @end()
```

### Cost impact of change in Billable Series for the Organization
```
sum( grafanacloud_org_metrics_billable_series{} @end() 
     - grafanacloud_org_metrics_billable_series{} @start() )
/ sum( grafanacloud_org_metrics_billable_series{} )
* sum( grafanacloud_org_metrics_overage{} )
```

### Calculate the change across the time range
```
delta( grafanacloud_org_metrics_billable_series{ } [ $__range ] )
```

### Calculate the Billable Series Count for each environment
```
sort_desc(
 sum by ( name ) (
   grafanacloud_instance_billable_usage{}
   * on (id) group_left( name ) grafanacloud_instance_info{ name=~".*prom.*"   }
 ) > 0 )
 ```
### Calculate the Series Cost for each environment: (I / O) * OC
```
sort_desc( ( (
     max( grafanacloud_instance_billable_usage{} ) by (id) > 0 ) # Stacks' Billable Series, where > 0
     / ignoring(id) group_left() # Divided by Org BillableSeries
       max( grafanacloud_org_metrics_billable_series{} ) by (id)
 ) * on (id) group_left(name)
     max by(id, name) (grafanacloud_instance_info{ name=~".*prom.*" }) # Include only these
) * on () group_left() sum (grafanacloud_org_metrics_overage{} ) # Org-wide Metrics bill, dollars:
```

### Billable Series Change % for each individual environment
```
sort_desc(
 sum by ( name ) (
     ((grafanacloud_instance_billable_usage{} @end() > 0) - grafanacloud_instance_billable_usage{} @start())
       / grafanacloud_instance_billable_usage{} @end()
       * on (id) group_left( name ) grafanacloud_instance_info{ name=~".*prom.*" } ) )
```

### Cost impact to individual environment of change in active series
```
sort_desc(
 sum by ( name ) (
    (( grafanacloud_instance_billable_usage{} @end() >0) - grafanacloud_instance_billable_usage{} @start())
       / on (org_id) group_left( name ) grafanacloud_org_metrics_billable_series{}
       * on (org_id) group_left( name ) grafanacloud_org_metrics_overage{}
       * on (id) group_left( name ) grafanacloud_instance_info{ name=~".*prom.*" } ))
```