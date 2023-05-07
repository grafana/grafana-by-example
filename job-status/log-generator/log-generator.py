import os
import sys
import time
from datetime import datetime
from datetime import datetime, timedelta
import requests
import json
import random


lokiWriteURL = "{a}://{u}:{k}@{h}:{p}{x}".format(
                    a=os.environ["GRAFANA_LOGS_PROTOCOL"],
                    u=os.environ["GRAFANA_LOGS_USERNAME"],
                    k=os.environ["GRAFANA_LOGS_API_KEY"],
                    h=os.environ["GRAFANA_LOGS_HOST"],
                    p=os.environ["GRAFANA_LOGS_PORT"],
                    x="/loki/api/v1/push")

print(lokiWriteURL )

#exit()

# https://grafana.com/docs/loki/latest/api/#push-log-entries-to-loki

def writeLoki2(logLabels, logMessageStr):
    try:
        nowNs = int(time.time() * 1000000000)
        stream = {
            "stream": logLabels,
            "values": [
                [str(nowNs), logMessageStr]
            ]
        }
        #print( "stream < {} >".format( stream ) )
        lokiData = { "streams": [ stream ] }
        headers = { "Content-Type": "application/json" }
        data = json.JSONEncoder().encode(lokiData)
        s = requests.session()
        r = s.post(lokiWriteURL, headers=headers, data=data)
        if not r.ok:
            print(data)
            print(r.ok)
            print(r.text)
            print(r.status_code)
    except Exception as e:
        print(e)
        
def writeLoki(jobName, logMessageStr):
    nowNs = int(time.time() * 1000000000)
    stream = {
        "stream": {"job": jobName},
        "values": [
            [str(nowNs), logMessageStr]
        ]
    }
    lokiData = { "streams": [ stream ] }
    headers = { "Content-Type": "application/json" }
    data = json.JSONEncoder().encode(lokiData)
    s = requests.session()
    r = s.post(lokiWriteURL, headers=headers, data=data)
    if not r.ok:
        print(data)
        print(r.ok)
        print(r.text)
        print(r.status_code)


def postLokiData(logMessageStr):
    headers = {"Content-Type": "application/json"}
    data = json.JSONEncoder().encode(lokiData)
    s = requests.session()
    r = s.post(lokiWriteURL, headers=headers, data=data)
    # print(data)
    # print(r.text)
    if not r.ok:
        print("Error ", r.status_code)
        print(r.text)


cmd = sys.argv[1] if len(sys.argv) > 1 else "unknown command"
if cmd == "test1":
    logJson = {"val1": random.randrange(
        1, 10), "val2": random.randrange(1, 10), }
    writeLoki("test1", json.dumps(logJson))

elif cmd == "test2":
    logMessageStr = "val1={} val2={}".format(
        random.randrange(1, 10), random.randrange(1, 10))
    writeLoki("test2", logMessageStr)

elif cmd == "service-status":
    durationMinutes = int(sys.argv[2])if len(sys.argv) > 3 else 60 # Run for 60 minutes
    ratePerMinute = float(sys.argv[3])if len(sys.argv) > 4 else 1 # Produce 1 sample per minute
    reportIntervalSec = float(sys.argv[4])if len(sys.argv) > 5 else 60

    delaySec = 60.0 / ratePerMinute
    timeoutSec = durationMinutes * 60
    timeoutTime = datetime.now() + timedelta(seconds=timeoutSec)
    startTime = datetime.now()
    sendMetricTime = datetime.now() + timedelta(seconds=delaySec)
    reportTime = datetime.now() + timedelta(seconds=reportIntervalSec)
    samplesSent = 0

    # Data set
    statusList = [ 'success', 'failure', 'unknown' ]
    statusFrequencyList = [ 8, 2, 0 ]
    jobNames = [ 'jobA', "jobB", "jobC" ]
     
    # Run
    while datetime.now() < timeoutTime:
        now = datetime.now()
        if now > sendMetricTime:
            sendMetricTime = now + timedelta(seconds=delaySec)
            nowdt = datetime.utcnow()
            nowSec = int( datetime.now().timestamp() )
            serviceStatus = random.choices(population=statusList, weights=statusFrequencyList)[0]
            logLine = { "name": jobNames[0], "state": serviceStatus, "ts": nowSec }
            logLabels = { "job": "test2", "state": serviceStatus }
            writeLoki2( logLabels, json.dumps( logLine ))
            print( logLabels, logLine )
            # Update sample values
        if now > reportTime:
            reportTime = now + timedelta(seconds=60)
            runTimeRemaining = (timeoutTime - now).seconds
            runTimeSeconds = (now - startTime).seconds
            runTimeMinutes = runTimeSeconds / 60
            samplesPerMinute = samplesSent /  runTimeSeconds * 60.0
            print( "{} {:.2f} {} {:.2f} {:.2f} {}".format(now, runTimeMinutes, samplesSent, samplesPerMinute, delaySec, runTimeRemaining))

elif cmd == "streams": # durationMinutes ratePerMinute nStreams
    durationMinutes = int(sys.argv[2])if len(sys.argv) > 2 else 1
    ratePerMinute = float(sys.argv[3])if len(sys.argv) > 3 else 1
    nStreams = int(sys.argv[4])if len(sys.argv) > 4 else 1
    delaySec = 60.0 / ratePerMinute
    timeoutSec = durationMinutes * 60
    timeoutTime = datetime.now() + timedelta(seconds=timeoutSec)
    reportTime = datetime.now() + timedelta(seconds=60)
    startTime = datetime.now()
    hostNames = ["host1", "host2", "host3", "host4"]
    serviceNames = ["config", "input", "output", "writer"]
    logLevels = ["info", "error", "warning", "debug"]
    print( "delaySec: {}".format(delaySec))
    while datetime.now() < timeoutTime:
        nowNs = int(time.time() * 1000000000)
        jobName = "streams"
        streamId = 1
        lokiData = {"streams": []}  # no streams
        for streamId in range(nStreams):
            logMessage = {"host":       random.choices(hostNames)[0],
                          "service":    random.choices(serviceNames)[0],
                          "level":      random.choices(logLevels)[0],
                          "value1":     streamId,  # random.randint(1,100),
                          "value2":     random.randint(1, 100)}
            #logMessageStr = "{msg}".format(msg=json.dumps(logMessage))
            streamData = {"stream": {"job": jobName, "id": streamId},
                          "values": [[str(nowNs), json.dumps(logMessage)]]}
            lokiData["streams"].append(streamData)
        #print(json.dumps(lokiData))
        #postLokiData( json.dumps( lokiData )  )
        postLokiData(lokiData)
        if delaySec > 0:
            time.sleep(delaySec)

elif cmd == "text1file":
    durationMinutes = int(sys.argv[2])if len(sys.argv) > 2 else 1
    ratePerMinute = int(sys.argv[3])if len(sys.argv) > 3 else 1
    delaySec = 60.0 / ratePerMinute
    timeoutSec = durationMinutes * 60
    timeoutTime = datetime.now() + timedelta(seconds=timeoutSec)
    reportTime = datetime.now() + timedelta(seconds=60)
    startTime = datetime.now()
    hostNames = ["host1", "host2", "host3", "host4"]
    serviceNames = ["config", "input", "output", "writer"]
    logLevels = ["info", "error", "warning", "debug"]
    #print( "rate: delaySec: {}".format(delaySec))
    f1 = open("log1.txt", "a")
    while datetime.now() < timeoutTime:
        logMessageStr = "{tsNs} {hostName} {serviceName} {value1} [{logLevel}] {value2}".format(
                        tsNs=time.time_ns(),
                        hostName=random.choices(hostNames)[0],
                        serviceName=random.choices(serviceNames)[0],
                        value1=random.randrange(1, 100),
                        logLevel=random.choices(logLevels)[0],
                        value2=random.randrange(1, 100))
        print(logMessageStr)
        f1.write(logMessageStr + "\n")
        f1.flush()
        if delaySec > 0:
            time.sleep(delaySec)  # writeLoki("text1", logMessageStr)
    f1.close()

else:
    print("Command unknown: {}".format(cmd))


exit()
