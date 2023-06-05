#!/usr/local/bin/python3
#
# OS
import sys, os, time, random, platform
from datetime import datetime, timedelta

# Mysql
#import mysql.connector

# Postgre
import psycopg2

# Prometheues
from prometheus_client import start_http_server
from prometheus_client import Summary
from prometheus_client import Counter
from prometheus_client import Gauge
from prometheus_client import Histogram
from prometheus_client import Info
import prometheus_client


# References
# https://github.com/prometheus/client_python
# https://dev.mysql.com/doc/connector-python/en/
# https://dev.mysql.com/doc/connector-python/en/connector-python-example-cursor-select.html
# https://dev.mysql.com/doc/refman/8.0/en/
# https://prometheus.io/docs/concepts/jobs_instances/

# Disabling Default Collector metrics
prometheus_client.REGISTRY.unregister(prometheus_client.GC_COLLECTOR)
prometheus_client.REGISTRY.unregister(prometheus_client.PLATFORM_COLLECTOR)
prometheus_client.REGISTRY.unregister(prometheus_client.PROCESS_COLLECTOR)

# Configure Prometheus HTTP Port for /metrics endpoint
prometheusHttpPort = int( os.environ.get('PROMTHEUS_HTTP_PORT', 8001) )
hostName = platform.node()

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

def getMetrics_dvd_payments(cnx,cr, metric_dvd_payments):
    paymentId = random.randint(17503, 32098)
    cr.execute("select * from payment where payment_id = {paymentId}".format(paymentId=paymentId))
    rows = cr.fetchone()
    payment_id, customer_id, staff_id, rental_id, amount, payment_date = rows
    metric_dvd_payments.labels(host=hostName, customer_id=customer_id).set(amount)


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "unknown command"

    if cmd == "metrics":
        print( len(sys.argv) )
        print( sys.argv )
        durationMinutes = getArg(2, 60) # Run for 60 minutes
        ratePerHour = getArg(3, 60) # Produce 60 samples per hour
        reportIntervalSec = getArg(4, 60) # Report every 60 seconds
        config = {  "dbHost": getArg(5,"127.0.0.1"),
                    "dbPort": getArg(6,"5432"),
                    "dbName": getArg(7,"dvdrental"),
                    "dbUser": getArg(8,"postgres"),
                    "dbPwd": getArg(9,"welcome1") }
        print("DB Config: {}".format(config), file=sys.stderr)
        # Configure timing
        delaySec = 3600.0 / ratePerHour
        timeoutSec = durationMinutes * 60
        timeoutTime = datetime.now() + timedelta(seconds=timeoutSec)
        startTime = datetime.now()
        sendMetricTime = datetime.now() + timedelta(seconds=delaySec)
        reportTime = datetime.now() + timedelta(seconds=reportIntervalSec)
        samplesSent = 0
        print( "delaySec: {} timeourSec: {} timeoutTime: {}".format(delaySec, timeoutSec, timeoutTime))

        # Database connection
        #cnx = mysql.connector.connect(user=dbUser, password=dbPass, host=dbHost, database="zm")
        #cr = cnx.cursor()
        try:
            cnx = psycopg2.connect(host=config["dbHost"], port=config["dbPort"], dbname=config["dbName"], user=config["dbUser"], password=config["dbPwd"])
            cr = cnx.cursor()
            print( "db connection succeed", file=sys.stderr)
        except Exception as e:
            print( "db connection failed: {}".format(e))
            exit(1)

        # Create the Promethues Metrics
        metric_dvd_payments = Gauge("dvd_payments", "dvd_payment amount by customer_id", ["host", "customer_id"])
        metric_dvd_samples = Counter("dvd_samples", "Number of dvd samples sent", ["host"])
        #metric3 = Info("test_service_version", "Version Information")
      
        # Start the Prometheus HTTP Server               
        start_http_server(prometheusHttpPort)

        # Set an Information metric sample value
        #metric3.info({"version": "1.0.0", "buildInfo": "test1"})

        # Run
        samplesSent = 0
        while datetime.now() < timeoutTime:
            now = datetime.now()
            if now > sendMetricTime:
                getMetrics_dvd_payments(cnx, cr, metric_dvd_payments)
                metric_dvd_samples.labels(host=hostName).inc()
                samplesSent += 1
                sendMetricTime = now + timedelta(seconds=delaySec)

            if now > reportTime: # Calc some internal stats
                runTimeRemaining = (timeoutTime - now).seconds
                runTimeSeconds = (now - startTime).seconds
                runTimeMinutes = runTimeSeconds / 60
                samplesPerMinute = samplesSent /  runTimeSeconds * 60.0
                print( "{} {:.2f} {} ss: {:.2f} {:.2f} {}".format(now, runTimeMinutes, samplesSent, samplesPerMinute, delaySec, runTimeRemaining),file=sys.stderr)
                reportTime = now + timedelta(seconds=60)
            time.sleep((sendMetricTime - now).seconds) # Sleep until next send metric time
        cr.close()
        cnx.close()

    elif cmd == "db-test":
        config = {  "dbHost": getArg(2,"127.0.0.1"),
                    "dbPort": getArg(3,"5432"),
                    "dbName": getArg(5,"dvdrental"),
                    "dbUser": getArg(6,"postgres"),
                    "dbPwd": getArg(7,"welcome1") }
        print( "DB Config: {}".format(config))
        cnx = psycopg2.connect(host=config["dbHost"], port=config["dbPort"], dbname=config["dbName"], user=config["dbUser"], password=config["dbPwd"])
        cr = cnx.cursor()
        #cr.execute("SELECT * from payment limit 10")
        paymentId = random.randint(17503, 32098)
        cr.execute("select * from payment where payment_id = {paymentId}".format(paymentId=paymentId))
        rows = cr.fetchall()
        for row in rows:
            print( row )
        cr.close()
        cnx.close()  

    elif cmd == "test":
        print("test")
        print( len(sys.argv) )
        print( sys.argv )
    else:
        print("Unknown Commands: [{}]\n".format(cmd))
        print( "Commands are:")
        print("  metrics <run time seconds> <rate per hour> <report interval seconds>[debug]")
        print("  db-test")
        print("  test")

    exit()