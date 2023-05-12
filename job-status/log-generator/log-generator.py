import os
import sys
import time
from datetime import datetime
from datetime import datetime, timedelta
import requests
import json
import random

jobName = os.environ.get('JOB_NAME', "jobA")

lokiWriteURL = "{a}://{u}:{k}@{h}:{p}{x}".format(
                    a=os.environ["GRAFANA_LOGS_PROTOCOL"],
                    u=os.environ["GRAFANA_LOGS_USERNAME"],
                    k=os.environ["GRAFANA_LOGS_API_KEY"],
                    h=os.environ["GRAFANA_LOGS_HOST"],
                    p=os.environ["GRAFANA_LOGS_PORT"],
                    x="/loki/api/v1/push")

print(lokiWriteURL )

# https://grafana.com/docs/loki/latest/api/#push-log-entries-to-loki

def lokiWriteStreams(logStreams, debug=False):
    if debug:
        print( "stream: {}".format(logStreams) )
    if lokiWriteURL != "":
        try:
            headers = { "Content-Type": "application/json" }
            data = json.JSONEncoder().encode(logStreams)
            #print( "L", data )
            s = requests.session()
            r = s.post(lokiWriteURL, headers=headers, data=data)
            if not r.ok:
                print(data)
                print(r.ok)
                print(r.text)
                print(r.status_code)
        except Exception as e:
            print(e)

def lokiCreateStream(labels, message):
    stream = {
        "stream": labels,
        "values": [ [str( int(time.time() * 1000000000) ), json.dumps( message ) ] ] }
    return { "streams": [ stream ] }

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
    v1Counter = 0
     
    # Run
    while datetime.now() < timeoutTime:
        now = datetime.now()
        if now > sendMetricTime:
            sendMetricTime = now + timedelta(seconds=delaySec)
            nowdt = datetime.utcnow()
            nowSec = int( datetime.now().timestamp() )
            serviceStatus = random.choices(population=statusList, weights=statusFrequencyList)[0]
            lokiWriteStreams(lokiCreateStream( labels = { "job": "job-status", "name": jobName, "state": serviceStatus },
                                               message =  { "name": jobName, "state": serviceStatus, "ts": nowSec, "v1": v1Counter } ) )

            # Update sample values
            v1Counter += 1
        if now > reportTime:
            reportTime = now + timedelta(seconds=60)
            runTimeRemaining = (timeoutTime - now).seconds
            runTimeSeconds = (now - startTime).seconds
            runTimeMinutes = runTimeSeconds / 60
            samplesPerMinute = samplesSent /  runTimeSeconds * 60.0
            print( "{} {:.2f} {} {:.2f} {:.2f} {}".format(now, runTimeMinutes, samplesSent, samplesPerMinute, delaySec, runTimeRemaining))

else:
    print("Command unknown: {}".format(cmd))


exit()
