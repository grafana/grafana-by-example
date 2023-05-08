#
import os
import json
import pprint
import requests
import time
from datetime import datetime, timedelta

# Flask
from flask import Flask
from flask import request

# Prometheus Client
import prometheus_client as pclient

# Disabling Default Collector metrics
pclient.REGISTRY.unregister(pclient.GC_COLLECTOR)
pclient.REGISTRY.unregister(pclient.PLATFORM_COLLECTOR)
pclient.REGISTRY.unregister(pclient.PROCESS_COLLECTOR)

# Create the Promethues Metrics
metric1 = pclient.Gauge("test_xyz", "Number", ["region", "service"] )
metric2 = pclient.Counter("test_ingest_events", "Total ingest events" )
metric3 = pclient.Info("test_service_version", "Version Information")

# Loki Config
try:
    lokiWriteURL = "{a}://{u}:{k}@{h}:{p}{x}".format(
                        a=os.environ["GRAFANA_LOGS_PROTOCOL"],
                        u=os.environ["GRAFANA_LOGS_USERNAME"],
                        k=os.environ["GRAFANA_LOGS_API_KEY"],
                        h=os.environ["GRAFANA_LOGS_HOST"],
                        p=os.environ["GRAFANA_LOGS_PORT"],
                        x="/loki/api/v1/push")
    print( "Remote write to loki configured: {}".format(lokiWriteURL))
except Exception as e:
    print( "Environment variable not set: {}".format(e))
    lokiWriteURL = ""
    print( "Remote write to loki not configured")

# https://grafana.com/docs/loki/latest/api/#push-log-entries-to-loki
def lokiWriteStreams(logStreams):
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

def lokiCreateStream(logLabels, logMessage):
    stream = {
        "stream": logLabels,
        "values": [ [str( int(time.time() * 1000000000) ), json.dumps( logMessage ) ] ] }
    return { "streams": [ stream ] }

# Ports
prometheusHttpPort = int( os.environ.get('PROMTHEUS_HTTP_PORT', 9001) )
#flaskHttpPort = int( os.environ.get('FASK_HTTP_PORT', 9002) )

# json: {'streams': [{'stream': {'job': 'test2', 'state': 'success'}, 'values': [['1683424065903416064', '{"name": "jobA", "state": "success", "ts": 1683424065}']]}]}

# Hashmap of metrics
jobList = {}
statusList = [ 'success', 'failure', 'unknown' ]

# Define the Prometheues metrics
pm = {
    "event_counter": pclient.Counter(   "job_event_counter",        "Total state events", ["name", "state"]),
    "stateTimeSec":  pclient.Counter(   "job_state_time",           "Total time in state", ["name", "state"] ),
    "timeInState":   pclient.Gauge(     "job_time_in_state" ,       "Time in state", ["name", "state"] ),
    "job_state":     pclient.Info(      "job_state",                "state",  ["name"]),
    "job_state_num": pclient.Gauge(     "job_state_num",            "State number", ["name"] ),
    "stateChangeTs": pclient.Gauge(     "job_state_change_ts",      "Time of state change", ["name", "state"] ),
}

# Log stream processor
def handleLogStream(streams):
    for stream in streams:
        streamLabels = stream["stream"]
        #print("S s{} v{}".format( stream["stream"], stream["values"]) )
        for m in stream["values"]:
            ts, lm = m # time stamp, log messages
            jlm = json.loads( lm )
            metricNameKey = "{}".format( jlm["name"] )
            print( ts, lm, metricNameKey )
            if metricNameKey in jobList.keys(): # Update Metrics
                print( "Updating metric: {}".format(metricNameKey))
                mlm =  jobList[metricNameKey]["metrics"]
                mlm["events"] += 1
                pm["event_counter"].labels(name=jlm["name"],state=jlm["state"]).inc() # Count Events
                #pm["job_state_num"].labels(name=jlm["name"]).set(statusList.index(jlm["state"]) + 1 if jlm["state"] in statusList else 0 )
                
                print("State: {} to {}".format( mlm["lastState"], jlm["state"]) )
                # Success to Failed: Generate a success event withing timing
                if mlm["lastState"] == "success" and jlm["state"] == "failure":
                    print( "S->F")
                    timeInState = jlm["ts"] - mlm["successTs"]
                    pm["stateTimeSec"].labels(name=jlm["name"], state=jlm["state"] ).inc( timeInState )
                    pm["timeInState"].labels(name=jlm["name"], state="success").set( timeInState )
                    pm["job_state_num"].labels(name=jlm["name"]).set( 2 ) # Current State is Failed
                    lokiWriteStreams(lokiCreateStream( { "job": "job-event", "state": "success", "name": jlm["name"]  }, { "time_in_state": timeInState} ) )
                    mlm["failedTs"] = jlm["ts"]

                # Failed to Success: Generate a failure event withing timing
                if mlm["lastState"] == "failure" and jlm["state"] == "success":
                    print( "F->S")
                    timeInState = jlm["ts"] - mlm["failedTs"]
                    pm["stateTimeSec"].labels(name=jlm["name"], state=jlm["state"] ).inc( timeInState )
                    pm["timeInState"].labels(name=jlm["name"], state="failure").set( timeInState )
                    pm["job_state_num"].labels(name=jlm["name"]).set( 1 ) # Current State is Success
                    lokiWriteStreams(lokiCreateStream( { "job": "job-event", "state": "failure", "name": jlm["name"]  }, { "time_in_state": timeInState} ) )
                    mlm["successTs"] = jlm["ts"]

                # Any state change
                if mlm["lastState"] != jlm["state"]:  # Update metrics  on state change
                    pm["job_state"].labels(name=jlm["name"] ).info( { "state": jlm["state"] } ) # Current state
                    pm["stateChangeTs"].labels(name=jlm["name"],state=jlm["state"]).set(jlm["ts"])
                    mlm["lastState"] = jlm["state"] # Change state
                    mlm["lastStateTs"] = jlm["ts"] # Time entering this state

            else: # Create Metrics for this job
                print( "New metric: {}".format(metricNameKey))
                jobList[metricNameKey] = { "metrics": {
                    "lastState": jlm["state"],
                    "lastStateTs": jlm["ts"],
                    "failedTs": jlm["ts"],
                    "successTs": jlm["ts"],
                    "events": 0 }
                }

        metric2.inc()

# Flask Application
app = Flask(__name__)

@app.route('/metrics', methods=['GET'])
def metrics():
    #return "<p>{}</p>".format( json.dumps(json.loads( jobList ), indent=2) ) 
    #return "<p>{}</p>".format( jobList )
    return "<p>{}</p><p>Now: {}</p>".format( 
            pprint.pformat( jobList, indent=2 ), int( datetime.now().timestamp() ))

@app.route('/loki/api/v1/push', methods=['GET', 'POST'])
def push():
    content_type = request.headers.get('Content-Type')
    if request.method == 'POST' and content_type == 'application/json':
        rj = request.json
        print("json: {}".format(rj))
        handleLogStream( rj["streams"] )
        lokiWriteStreams( rj )
        #print( request.data )
        return "<p>post</p>"
    else:
        return "<p>get</p>"
    
@app.route("/status")
def status():
    return "<p>ok: {}</p>".format(int( datetime.now().timestamp() ))

# Prometheus Client
pclient.start_http_server(prometheusHttpPort)

if __name__ == '__main__':
    # Prometheus Client
    # pclient.start_http_server(prometheusHttpPort)
    # app.run(host="localhost", port=9002, debug=True)
    # print("e")
    pass

# flask --app log-stream-processor run