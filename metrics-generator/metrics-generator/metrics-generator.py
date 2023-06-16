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

if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "unknown command"

    if cmd == "regions":
        metricPrefix =      getArg(2, "test") 
        numberOfRegions =   getArg(3, 5) 
        numberOfServices =  getArg(4, 5) 
        numberOfHosts =     getArg(5, 5)
        durationMinutes =   getArg(6, 60) 
        ratePerMinute =     getArg(7, 1.0)  # Produce 1 sample per minute
        reportIntervalSec = getArg(8, 60.0) 

        delaySec = 60.0 / ratePerMinute
        timeoutSec = durationMinutes * 60
        timeoutTime = datetime.now() + timedelta(seconds=timeoutSec)
        startTime = datetime.now()
        sendMetricTime = datetime.now() + timedelta(seconds=delaySec)
        reportTime = datetime.now() + timedelta(seconds=reportIntervalSec)
        samplesSent = 0

        # Data set
        regionList =    [ "region{}".format(i) for i in range(numberOfRegions) ]
        serviceList =   [ "service{}".format(i) for i in range(numberOfServices) ]
        hostList =      [ "host{}".format(i) for i in range(numberOfHosts) ]
        statusList = [ 1, 2, 3, 4, 5 ]
        # Service ${__data.fields["service"]} Region ${__field.name} Value ${__value.text} Grafana Dashboard datalink

        # Precalculate Initial values
        statusData = [ [ [ random.choices(statusList)[0] for i in range(numberOfRegions) ] for ii in range(numberOfServices) ] for ii in range(numberOfHosts) ]
        # Create the Promethues Metrics
        metric1 = Gauge("{}_service_status".format(metricPrefix), "Regional Services Test Metric", ["region", "service", "host"] )
        metric2 = Counter("{}_service_samples".format(metricPrefix), "Regional Services Test Metric Samples Sent" )
        metric3 = Info("{}_service_version".format(metricPrefix), "Version Information")
        METRIC_GENERATION_TIME = Summary('test_service_metric_generation_seconds', 'Time spent generating metrics')

        # Start the Prometheus HTTP Server               
        start_http_server(prometheusHttpPort)

        # Set an Information metric sample value
        metric3.info( { "version": "1.0.0", "buildInfo": "{}".format(metricPrefix) } )

        # Run
        while datetime.now() < timeoutTime:
            now = datetime.now()
            if now > sendMetricTime:
                sendMetricTime = now + timedelta(seconds=delaySec)
                nowdt = datetime.utcnow()
                for region in range( numberOfRegions ):
                    for service in range( numberOfServices ):
                        for host in range( numberOfHosts ):
                            # Set a metric sample value: set the label values and the sample value
                            #print( region, service, host, statusData[region][service][host] )
                            metric1.labels(region=regionList[ region ], service=serviceList[ service ], host=hostList[ host ]).set( statusData[region][service][host] )
                samplesSent += 1

                # Increment a Counter metric
                metric2.inc()

                # Update sample values
                statusData = [ [ [ ((statusData[r][s][h] + 1) % len( statusList )) 
                                for r in range(numberOfRegions) ] 
                                    for s in range(numberOfServices) ]
                                        for h in range(numberOfHosts) ]
                #print("Post ", statusData )
            if now > reportTime:
                reportTime = now + timedelta(seconds=60)
                runTimeRemaining = (timeoutTime - now).seconds
                runTimeSeconds = (now - startTime).seconds
                runTimeMinutes = runTimeSeconds / 60
                samplesPerMinute = samplesSent /  runTimeSeconds * 60.0
                print( "{} {:.2f} {} {:.2f} {:.2f} {}".format(now, runTimeMinutes, samplesSent, samplesPerMinute, delaySec, runTimeRemaining))
        
    elif cmd == "test":
        print("test")
    else:
        print("Unknown Commands: [{}]\n".format(cmd))
        print( "Commands are:")
        print("  regionalServices <number of regions> <number of services> <run time seconds> <rate per minute> [debug]")
        print("  test")

    exit()