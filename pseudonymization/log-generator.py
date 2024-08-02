import os, sys, time
import requests, json, random
from datetime import datetime, timedelta



lokiWriteURL = "{a}://{u}:{k}@{h}:{p}{x}".format(
                    a=os.environ.get("GRAFANA_LOGS_PROTOCOL", "http"),
                    u=os.environ.get("GRAFANA_LOGS_USERNAME", ""),
                    k=os.environ.get("GRAFANA_LOGS_API_KEY", ""),
                    h=os.environ.get("GRAFANA_LOGS_HOST", "localhost"),
                    p=os.environ.get("GRAFANA_LOGS_PORT", "3100"),
                    x="/loki/api/v1/push")
jobName = os.environ.get('LOKI_JOB_NAME', "j1")
#print(lokiWriteURL )

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

cmd = sys.argv[1] if len(sys.argv) > 1 else "unknown command"
if cmd == "test1":
    nameList = [ "Edward", "Charles",  "William" ]
    idList = [ "1111", "2222",  "3333" ]
    lokiWriteStreams( lokiCreateStream( {"job":"j1", "app":"a1"},
                        {"name": random.choices(nameList)[0], "id": random.choices(idList)[0]  } ), debug=True )

elif cmd == "send-logs-1":
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
    nameList = [ "Edward", "Charles",  "William", "Henry", "George" ]
    idList = [ "192.168.0.1", "192.168.1.1",  "192.168.1.2",  "192.168.1.3", "192.168.1.4" ]
    userDataList = list( zip( nameList, idList ) )
    # Run
    while datetime.now() < timeoutTime:
        now = datetime.now()
        if now > sendMetricTime:
            sendMetricTime = now + timedelta(seconds=delaySec)
            samplesSent += 1
            userData =  random.choices( userDataList )[0]
            lokiWriteStreams( lokiCreateStream( {"job":jobName, "app":"a1"},
                                    {"name": userData[0], "id": userData[1], "cnt": samplesSent  } ),
                                      debug=True )
        else:
            pauseSec = sendMetricTime - now
            time.sleep( pauseSec.total_seconds()  )
            
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
