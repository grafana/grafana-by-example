from prometheus_client import start_http_server
from prometheus_client import Summary
from prometheus_client import Counter
from prometheus_client import Gauge
from prometheus_client import Histogram
from prometheus_client import Info
import prometheus_client
import random
import time
import sys, os
from datetime import datetime, timedelta
import platform


# References
# https://github.com/prometheus/client_python

# Disabling Default Collector metrics
prometheus_client.REGISTRY.unregister(prometheus_client.GC_COLLECTOR)
prometheus_client.REGISTRY.unregister(prometheus_client.PLATFORM_COLLECTOR)
prometheus_client.REGISTRY.unregister(prometheus_client.PROCESS_COLLECTOR)

prometheusHttpPort = int( os.environ.get('PROMTHEUS_HTTP_PORT', 8001) )

if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "unknown command"

    if cmd == "regionalServices":
        numberOfRegions = int(sys.argv[2])if len(sys.argv) > 2 else 5
        numberOfServices = int(sys.argv[3])if len(sys.argv) > 3 else 5
        durationMinutes = int(sys.argv[4])if len(sys.argv) > 4 else 60 # Run for 60 minutes
        ratePerMinute = float(sys.argv[5])if len(sys.argv) > 5 else 1 # Produce 1 sample per minute
        delaySec = 60.0 / ratePerMinute
        timeoutSec = durationMinutes * 60
        timeoutTime = datetime.now() + timedelta(seconds=timeoutSec)
        startTime = datetime.now()
        sendMetricTime = datetime.now() + timedelta(seconds=delaySec)
        reportTime = datetime.now() + timedelta(seconds=60)
        samplesSent = 0

        # Data set
        regionList = ['AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY']
        serviceList = [ 'compute', 'database', 'storage', 'network', 'security', 'kubernetes', 'containers', 'web-apps', 'mobile-apps', 'serveless', 'ml-ai', 'visualization' ]
        statusList = [ 1, 2, 3, 4, 5 ]
        # Service ${__data.fields["service"]} Region ${__field.name} Value ${__value.text} Grafana Dashboard datalink

        # Initial values
        statusData = [ [ random.choices(statusList)[0] for i in range(numberOfRegions) ] for ii in range(numberOfServices) ]

        # Create the Promethues Metrics
        metric1 = Gauge("test_service_status", "Regional Services Test Metric", ["region", "service"] )
        metric2 = Counter("test_service_samples", "Regional Services Test Metric Samples Sent" )
        metric3 = Info("test_service_version", "Version Information")
        METRIC_GENERATION_TIME = Summary('test_service_metric_generation_seconds', 'Time spent generating metrics')

        # Start the Prometheus HTTP Server               
        start_http_server(prometheusHttpPort)

        # Set a metric sample value
        metric3.info({"version": "1.0.0", "buildInfo": "test1"})

        # Run
        while datetime.now() < timeoutTime:
            now = datetime.now()
            if now > sendMetricTime:
                sendMetricTime = now + timedelta(seconds=delaySec)
                nowdt = datetime.utcnow()
                for region in range( numberOfRegions ):
                    for service in range( numberOfServices ):
                        # Set a metric sample value: set the label values and the sample value
                        metric1.labels(region=regionList[ region ], service=serviceList[ service ]).set( statusData[region][service] )
                samplesSent += 1
                metric2.inc()

                # Update sample values
                statusData = [[ ((statusData[r][s] + 1) % len( statusList )) for r in range(numberOfRegions) ] for s in range(numberOfServices) ]
            if now > reportTime:
                reportTime = now + timedelta(seconds=60)
                runTimeSeconds = (now - startTime).seconds
                runTimeMinutes = runTimeSeconds / 60
                samplesPerMinute = samplesSent /  runTimeSeconds * 60.0
                print( "{} {:.2f} {} {:.2f} {:.2f}".format(now, runTimeMinutes, samplesSent, samplesPerMinute, delaySec))
        
    elif cmd == "test":
        print("test")
    else:
        print("Unknown Commands: [{}]\n".format(cmd))
        print( "Commands are:")
        print("  regionalServices <number of regions> <number of services> <run time seconds> <rate per minute> [debug]")
        print("  test")

    exit()