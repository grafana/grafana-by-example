import sys, os, math, time, random, uuid
from datetime import datetime, timedelta
import platform
import logging

import prometheus_client
from prometheus_client import start_http_server
from prometheus_client import Summary, Counter, Gauge, Histogram, Info

logging.getLogger().setLevel(logging.INFO)

# References
# https://github.com/prometheus/client_python
# https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/receiver/prometheusreceiver/README.md


# Disabling Default Collector metrics
prometheus_client.REGISTRY.unregister(prometheus_client.GC_COLLECTOR)
prometheus_client.REGISTRY.unregister(prometheus_client.PLATFORM_COLLECTOR)
prometheus_client.REGISTRY.unregister(prometheus_client.PROCESS_COLLECTOR)

# Promethehus HTTP Server
prometheusHttpPort = int( os.environ.get('PROMTHEUS_HTTP_PORT', 8001) )

def roundDatetimeUp(dt, delta):
    return datetime.min + math.ceil((dt - datetime.min) / delta) * delta

def getArg(n, default="NONE"):
    # Use type of default set result type
    v = default if len(sys.argv) <= n else sys.argv[n]  
    if isinstance(default, int):
        v = int(v)
    elif isinstance(default, float):
        v = float(v)
    elif isinstance(default, bool):
        v = bool(v)
    else:
        v = str(v)
    return v

class SimpleMetric():
    def __init__(self, metricPrefix, intevalSec, durationMinutes, traceID):
        self.intervalSec = intevalSec
        self.endTime = endTime = datetime.now() + timedelta(minutes=durationMinutes)
        self.metricPrefix = metricPrefix
        self.traceID = traceID
  
    def start(self): 
        # References
        # https://prometheus.github.io/client_python/instrumenting/exemplars/
        # https://cloud.google.com/stackdriver/docs/managed-prometheus/exemplars
        # https://grafana.com/docs/grafana/latest/datasources/prometheus/configure-prometheus-data-source/
        # To see openmetric format use
        # curl -H 'Accept: application/openmetrics-text' localhost:8001/metrics
        # To see Prometheus formet use
        # curl localhost:8001/metrics
        
        # Create the Promethues Metrics
        # Only Counter and Histogram support Exemplars
        metric1 = Gauge( "{}_guage1".format(self.metricPrefix),    "Simple Metric Guage1",   ["job" ])
        metric2 = Counter( "{}_counter1".format(self.metricPrefix), "Simple Metric Counter1", ["job" ] )
        metric3 = Counter( "{}_counter2".format(self.metricPrefix), "Simple Metric Counter2", ["job" ] )
        metric4 = Histogram( "{}_hist1".format(self.metricPrefix), "Simple Metric Histogram1", [ "job" ]  )

        n = 0
        startTime = datetime.now()
        while (datetime.now() < self.endTime):
            traceID = "{:032d}".format(n)
            spanID = uuid.uuid4().hex
            sendMetricTime = roundDatetimeUp(datetime.now(), timedelta(seconds=self.intervalSec))
            waitForSec = (sendMetricTime - datetime.now()).total_seconds()
            logging.info( "{} now: {} next: {} waitSec: {} end: {}".format(n, datetime.now(), sendMetricTime, waitForSec, self.endTime ))
            time.sleep(waitForSec) # Sleep until next send metric time
          
           # Update the metric values
            metric1.labels( job="simple1" ).set( random.randint(1,10) )
            metric2.labels( job="simple1" ).inc( exemplar={ "trace_id": traceID, "span_id": spanID } ) # Exemplar labels match OTLP defaults
            metric3.labels( job="simple1" ).inc( exemplar={ "traceID": traceID } ) # Exemplar label "traceID" matches Grafana correlation default
            metric4.labels( job="simple1" ).observe( random.random(), exemplar={ "traceID": traceID }) # Exemplar, note label "traceID"
            n = n + 1


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "unknown command"

    if cmd == "simplemetric1":
        traceID = os.environ.get( "METRIC_GEN_SIMPLE_TRACE_ID", "00000000000000000000000000000001" )
        metricPrefix =      getArg(1, "simplemetric") 
        durationMinutes =   getArg(2, 360) 
        produceIntervalSec = getArg(3, 60)  # Produce metrics every nn seconds
        reportIntervalSec = getArg(4, 300.0) 
        r = SimpleMetric( metricPrefix, produceIntervalSec, durationMinutes, traceID)
        start_http_server(prometheusHttpPort)
        r.start()      
            
    elif cmd == "test":
        print("test")
    else:
        print("Unknown Commands: [{}]\n".format(cmd))
        print( "Commands are:")
        print("  SimpleMetric <metric Prefix> <duration minutes> <metrics interval seconds>")
        print("  regionalServices <number of regions> <number of services> <run time seconds> <rate per minute> [debug]")
        print("  histogram1 - generate a classic histogram")

    exit()