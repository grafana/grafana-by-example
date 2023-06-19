from prometheus_client import start_http_server
from prometheus_client import Summary
from prometheus_client import Counter
from prometheus_client import Gauge
from prometheus_client import Histogram
from prometheus_client import Info
import prometheus_client

import sys, os, math, time, random
from datetime import datetime, timedelta
import platform


# References
# https://github.com/prometheus/client_python

# Disabling Default Collector metrics
prometheus_client.REGISTRY.unregister(prometheus_client.GC_COLLECTOR)
prometheus_client.REGISTRY.unregister(prometheus_client.PLATFORM_COLLECTOR)
prometheus_client.REGISTRY.unregister(prometheus_client.PROCESS_COLLECTOR)

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

class Regions():
    def __init__(self, metricPrefix,r, s, h, intevalSec, durationSeconds):
        self.regions = r
        self.services = s
        self.hosts = h
        self.intervalSec = intevalSec
        self.endTime = endTime = datetime.now() + timedelta(seconds=durationSeconds)
        self.metricPrefix = metricPrefix
        # Data set
        self.regionList =    [ "region{}".format(i) for i in range(self.regions) ]
        self.serviceList =   [ "service{}".format(i) for i in range(self.services) ]
        self.hostList =      [ "host{}".format(i) for i in range(self.hosts) ]
        self.statusDataRange = self.regions * self.services * self.hosts
        self.statusDataBase = [ [ [ 0 for i in range(self.regions) ] for ii in range(self.services) ] for iii in range(self.hosts) ]
        v = 1
        for r in range( self.regions ):
            for s in range( self.services ):
                for h in range( self.hosts ):
                    self.statusDataBase[r][s][h] = v
                    v += self.statusDataRange
        print( "statusDataRange: {}".format(self.statusDataRange))
        print( "statusData: {}".format(self.statusDataBase))
        self.offset = 0
  
    def start(self): 
        # Create the Promethues Metricsç
        metric1 = Gauge("{}_service_status".format(self.metricPrefix), "Regional Services Test Metric", ["region", "service", "host"] )
        metric2 = Counter("{}_service_samples".format(self.metricPrefix), "Regional Services Test Metric Samples Sent" )
        metric3 = Info("{}_service_version".format(self.metricPrefix), "Version Information")
        metric4 = Gauge("{}_uptime".format(self.metricPrefix), "Regional Services Uptime" )

        #METRIC_GENERATION_TIME = Summary('test_service_metric_generation_seconds', 'Time spent generating metrics')
        metric3.info( { "version": "1.0.0", "buildInfo": "{}".format(self.metricPrefix) } )
   
        n = 0
        statusDataOffset = 0
        startTime = datetime.now()
        while (datetime.now() < self.endTime):
            metric4.set((datetime.now() - startTime).total_seconds())
            sendMetricTime = roundDatetimeUp(datetime.now(), timedelta(seconds=self.intervalSec))
            waitForSec = (sendMetricTime - datetime.now()).total_seconds()
            print( "{} now: {} next: {} waitSec: {} ".format(n, datetime.now(), sendMetricTime, waitForSec ))
            time.sleep(waitForSec) # Sleep until next send metric time
            n = n + 1
            for region in range( self.regions ):
                for service in range( self.services ):
                    for host in range( self.hosts ):
                        metric1.labels(region=self.regionList[ region ],
                                        service=self.serviceList[ service ], 
                                        host=self.hostList[ host ]).set(self.statusDataBase[region][service][host] + statusDataOffset)
            metric2.inc()
            #samplesSent += 1
            statusDataOffset = (statusDataOffset + 1 ) % self.statusDataRange

if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "unknown command"

    if cmd == "test1":
        r = Regions( "test1", 2, 2, 2, 2, 120 )
        start_http_server(prometheusHttpPort)
        r.start()

    elif cmd == "regions":
        metricPrefix =      getArg(2, "test") 
        numberOfRegions =   getArg(3, 5) 
        numberOfServices =  getArg(4, 5) 
        numberOfHosts =     getArg(5, 5)
        durationMinutes =   getArg(6, 60) 
        produceIntervalSec = getArg(7, 60)  # Produce metrics every nn seconds
        reportIntervalSec = getArg(8, 300.0) 

        #delaySec = 60.0 / ratePerMinute
        timeoutSec = durationMinutes * 60
        timeoutTime = datetime.now() + timedelta(seconds=timeoutSec)
        startTime = datetime.now()
        #sendMetricTime = datetime.now() + timedelta(seconds=delaySec)
        sendMetricTime = roundDatetimeUp(datetime.now(), timedelta(seconds=produceIntervalSec))
        reportTime = datetime.now() + timedelta(seconds=reportIntervalSec)
        samplesSent = 0

        # Data set
        regionList =    [ "region{}".format(i) for i in range(numberOfRegions) ]
        serviceList =   [ "service{}".format(i) for i in range(numberOfServices) ]
        hostList =      [ "host{}".format(i) for i in range(numberOfHosts) ]
        statusList = [ 1, 2, 3, 4, 5 ]
        # Service ${__data.fields["service"]} Region ${__field.name} Value ${__value.text} Grafana Dashboard datalink

        # Precalculate Initial values
        #statusData = [ [ [ random.choices(statusList)[0] for i in range(numberOfRegions) ] for ii in range(numberOfServices) ] for iii in range(numberOfHosts) ]
        #statusData = [ [ [ i * ii * iii for i in range(numberOfRegions) ] for ii in range(numberOfServices) ] for iii in range(numberOfHosts) ]
        statusDataRange = numberOfRegions * numberOfServices * numberOfHosts
        statusDataBase = [ [ [ 0 for i in range(numberOfRegions) ] for ii in range(numberOfServices) ] for iii in range(numberOfHosts) ]
        v = 1
        for r in range( numberOfRegions ):
            for s in range( numberOfServices ):
                for h in range( numberOfHosts ):
                    statusDataBase[r][s][h] = v
                    v += statusDataRange
        print( "statusDataRange: {}".format(statusDataRange))
        print( "statusData: {}".format(statusDataBase))
        #statusData = statusDataBase
        statusDataOffset = 0
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
            if datetime.now() > sendMetricTime:
                print("Now: {} statusDataOffset: {}".format(datetime.now(), statusDataOffset))
                #sendMetricTime = now + timedelta(seconds=delaySec)
                nowdt = datetime.utcnow()
                for region in range( numberOfRegions ):
                    for service in range( numberOfServices ):
                        for host in range( numberOfHosts ):
                            # Set a metric sample value: set the label values and the sample value
                            #print( region, service, host, statusData[region][service][host] )
                            metric1.labels(region=regionList[ region ],
                                            service=serviceList[ service ], 
                                            host=hostList[ host ]).set( statusDataBase[region][service][host] + statusDataOffset)

                # Increment samples counter and update sample values
                metric2.inc()
                samplesSent += 1
                statusDataOffset = (statusDataOffset + 1 ) % statusDataRange

                # Sechedule next send metrics
                sendMetricTime = roundDatetimeUp(datetime.now(), timedelta(seconds=produceIntervalSec))
                waitFor  = (sendMetricTime - datetime.now()).seconds
                #print( sendMetricTime, waitFor )
                if waitFor > 0:
                    time.sleep(waitFor) # Sleep until next send metric time

            if datetime.now() > reportTime:
                reportTime = datetime.now() + timedelta(seconds=reportIntervalSec)
                runTimeRemaining = (timeoutTime - datetime.now()).seconds
                runTimeSeconds = (datetime.now() - startTime).seconds
                runTimeMinutes = runTimeSeconds / 60
                samplesPerMinute = samplesSent /  runTimeSeconds * 60.0
                print( "{} {:.2f} {} {:.2f} {:.2f} {}".format(datetime.now(), runTimeMinutes, samplesSent, samplesPerMinute, produceIntervalSec, runTimeRemaining))
            
            
            
    elif cmd == "test":
        print("test")
    else:
        print("Unknown Commands: [{}]\n".format(cmd))
        print( "Commands are:")
        print("  regionalServices <number of regions> <number of services> <run time seconds> <rate per minute> [debug]")
        print("  test")

    exit()