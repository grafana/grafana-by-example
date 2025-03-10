#!/usr/local/bin/python3
import os, sys, time, json
import requests
from datetime import datetime, timedelta

from random import randint, choices
import sqlite3

# Pre configured stacks
stacks = [
    (100001, "stack1"),
    (101002, "stack2"),
    (100003, "stack3") ]

d1 = { "data": ["a","b","c" ], "status": "test" } # Dictionary

# https://prometheus.io/docs/prometheus/latest/querying/api/#querying-metric-metadata


# For GRAFANA_METRICS_API_KEY create a Grafana Cloud Access Policy with read access to metrics
#
def getEnvironmentConfig():
    return { "QUERY_URL": os.environ.get('GRAFANA_METRICS_QUERY_URL', 'None'),
             "USER": os.environ.get('GRAFANA_METRICS_USERNAME', 'None'),
             "API_KEY": os.environ.get('GRAFANA_METRICS_API_KEY', 'None'),
             "METICS_HOST": os.environ.get('GRAFANA_METRICS_HOST', 'None'),
             "HTTP_PROTOCOL": os.environ.get('GRAFANA_HTTP_PROTOCOL', 'https'),
             "QUERY_API_PATH": os.environ.get('GRAFANA_METRICS_QUERY_PATH', 'api/prom/api/v1'),
             "SQLITE_DB_FILE": os.environ.get('GRAFANA_SQLITE_DB_PATH', 'test1.sqlite') }

config = getEnvironmentConfig()
print( config )

def queryURL(user, apiPath):
    return "{p}://{u}:{k}@{h}/{q}/{a}".format( 
        p=config["HTTP_PROTOCOL"],  u=user, k=config["API_KEY"],
        h=config["METICS_HOST"], q=config["QUERY_API_PATH"], a=apiPath)

def getMetricNamesList( stackId ):
    q = queryURL( stackId, "label/__name__/values" )
    r = requests.get(q)
    print( q )
    #j1 = d1
    j1 = json.loads( r.content )
    print ("getMetricNamesList", stackId, j1['status'])
    #print (j1['data'])
    return j1



nArgs = len(sys.argv)
cmd = sys.argv[1] if nArgs > 1 else "help"
if cmd == "tables-create":
    c = sqlite3.connect(config["SQLITE_DB_FILE"])
    cursor = c.cursor()

    cursor.execute("CREATE TABLE IF NOT EXISTS stacks \
                   (id NUMBERIC PRIMARY KEY, name TEXT, \
                    valid NUMERIC, \
                    total_metrics NUMBERIC, total_series NUMBERIC, \
                    total_labels NUMBERIC, total_unique_labels NUMBERIC, \
                    UNIQUE(id, name))")
    
    cursor.execute("CREATE TABLE IF NOT EXISTS metrics \
                   (id NUMBERIC PRIMARY KEY, name TEXT, metrics TEXT, \
                   UNIQUE(id))")
    
    cursor.execute("CREATE TABLE IF NOT EXISTS labels \
                   (id NUMBERIC PRIMARY KEY, name TEXT, labels TEXT, \
                   UNIQUE(id))")
                   
    print(c.total_changes)
    c.commit()
    c.close()

elif cmd == "stacks-insert":
    c = sqlite3.connect(config["SQLITE_DB_FILE"])
    cursor = c.cursor()
    for i in stacks:
        try:
            cursor.execute("INSERT INTO stacks (id, name, valid) VALUES(?, ?, TRUE)", ( i[0], i[1] ) )
            print( "inserted" ,i ) 
        except Exception as e:
            print( "failed", i ) 
            print( e )
    c.commit()
    c.close()

elif cmd == "stacks-print":
    c = sqlite3.connect(config["SQLITE_DB_FILE"])
    cursor = c.cursor()
    rows = cursor.execute("SELECT id, name, valid from stacks").fetchall()
    for i in rows:
        id, name, valid = i
        if valid:
            print( id, name, valid )
    c.close()

elif cmd == "metrics-insert-names":
    c = sqlite3.connect(config["SQLITE_DB_FILE"])
    cr = c.cursor()
    rows = cr.execute("SELECT id, name, valid from stacks").fetchall()
    for i in rows:
        id, name, valid = i
        if valid:
            print( "Inserting", id, name, valid )
            cr.execute("INSERT INTO metrics (id, name, metrics) VALUES(?, ?, ?)", (id, name, json.dumps(d1) ) )
    c.commit()
    c.close()

elif cmd == "labels-insert-names":
    c = sqlite3.connect(config["SQLITE_DB_FILE"])
    cr = c.cursor()
    rows = cr.execute("SELECT id, name, valid from stacks").fetchall()
    for i in rows:
        id, name, valid = i
        if valid:
            print( "Inserting", id, name, valid )
            cr.execute("INSERT INTO labels (id, name) VALUES(?, ?)", (id, name ) )
    c.commit()
    c.close()

elif cmd == "metrics-update-names-all-stacks":
    c = sqlite3.connect(config["SQLITE_DB_FILE"])
    cr = c.cursor()
    rows = cr.execute("SELECT id, name, valid from stacks").fetchall()
    for i in rows:
        id, name, valid = i
        if valid:
            print( "Updating", id, name, valid )
            m1 = getMetricNamesList( id )
            metrics = m1['data']
            print( id,  metrics )
            cr.execute("UPDATE metrics SET metrics = ? WHERE id = ?", (json.dumps(metrics), id ) )
    c.commit()
    c.close()

elif cmd == "metrics-update-names-stack":
    stackId = int( sys.argv[2] )
    c = sqlite3.connect(config["SQLITE_DB_FILE"])
    cr = c.cursor()
    print( "Updating", stackId )
    m1 = getMetricNamesList( stackId )
    print( m1 )
    metrics = m1['data']
    print( stackId,  metrics )
    cr.execute("UPDATE metrics SET metrics = ? WHERE id = ?", (json.dumps(metrics), stackId ) )
    c.commit()
    c.close()

elif cmd == "metrics-names-print":
    c = sqlite3.connect(config["SQLITE_DB_FILE"])
    cr = c.cursor()
    rows = cr.execute("SELECT id, metrics from metrics").fetchall()
    for i in rows:
        id, metrics = i
        j = json.loads(metrics)
        print( id, len( metrics ), len(j) )
    c.commit()
    c.close()

elif cmd == "label-update-names-stack":
    # https://prometheus.io/docs/prometheus/latest/querying/api/#getting-label-names
    stackId = int( sys.argv[2] )
    q = queryURL( stackId, "labels" ) # works
    r = requests.get(q)
    j1 = json.loads( r.content )
    labels = j1['data']
    c = sqlite3.connect(config["SQLITE_DB_FILE"])
    cr = c.cursor()
    print( "Updating labels: ", stackId,  labels )
    cr.execute("UPDATE labels SET labels = ? WHERE id = ?", (json.dumps(labels), stackId ) )
    c.commit()
    c.close()
    print(j1)

elif cmd == "metric-tsdb-stats":
    stackId = int( sys.argv[2] )
    #q = queryURL( stackId, "status/tsdb" )
    q = queryURL( stackId, "labels" ) # works
    r = requests.get(q)
    j1 = json.loads( r.content )
    print ("metric-tsdb-stats", stackId, j1['status'])
    print ("metric-tsdb-stats", stackId, j1['data'])

elif cmd == "metadata":
    # https://grafana.com/docs/mimir/latest/references/http-api/#get-metric-metadata
    stackId = int( sys.argv[2] )
    q = queryURL( stackId, "metadata" )
    r = requests.get(q)
    print( "query", q )
    print( "r", r)
    #j1 = d1
    j1 = json.loads( r.content )
    print ("metric-tsdb-stats", stackId, j1['status'])
    print ("metric-tsdb-stats", stackId, j1['data'])

elif cmd == "get-metrics-list":
    stackId = int( sys.argv[2] )
    m1 = getMetricNamesList( stackId )
    print( m1 )

elif cmd == "test":
    print( "test" ) 
    d1 = { "data": ["a","b","c" ] } # Dictionary
    s1 = json.dumps(d1) # String
    j1 = json.loads(s1) # Dictionary / JSON
    print( d1, s1, j1['data'] )

elif cmd == "help":
    print( "Help:")
else:
    print( "unknown command: ({})".format(cmd))

exit()

