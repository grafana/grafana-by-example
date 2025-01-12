package org.example.rideshare;

import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import java.time.temporal.ChronoUnit;
import java.util.concurrent.atomic.AtomicLong;

// Exceptions
import java.io.IOException;

// Added for custom metrics
import io.prometheus.client.Counter;
import io.prometheus.client.exporter.HTTPServer;
import io.prometheus.client.CollectorRegistry;
import io.prometheus.metrics.model.registry.*;

// References
// https://github.com/prometheus/client_java/tree/main/examples/example-exemplars-tail-sampling

@Service
public class OrderService {
    HTTPServer promServer;
    Counter searchCounterMetric;

    public OrderService() {
        // Create a custom Appliation Metric
        try {
            searchCounterMetric = Counter
                .build()
                .name("appsearches")
                .help("Count of Searches")
                .labelNames("job", "type")
                .register();
            promServer = new HTTPServer( 8002 );
        } catch( Exception e ) {
            e.printStackTrace();
        }
        
        // Attempt to rename trace_id to traceID - TBD
        //PrometheusRegistry pr1 = PrometheusRegistry.defaultRegistry;
        //pr1.config().commonTags("trace_id", "traceID");
        //CollectorRegistry defaultRegistry = CollectorRegistry.defaultRegistry;
        //defaultRegistry.config().commonTags("trace_id", "traceID");
    }

    //Meter meter = OpenTelemetry.getMeterProvider().get("your.application.name");

    public static final Duration OP_DURATION = Duration.of(200, ChronoUnit.MILLIS);

    public synchronized void findNearestVehicle(int searchRadius, String vehicle) {
        AtomicLong i = new AtomicLong();
        Instant end = Instant.now()
                .plus(OP_DURATION.multipliedBy(searchRadius));
        while (Instant.now().compareTo(end) <= 0) {
            i.incrementAndGet();
        }

        if (vehicle.equals("car")) {
            checkDriverAvailability(searchRadius);
        }
        // Metric
        searchCounterMetric.labels("appjava1", "findNearestVehicle").inc();
    }

    private void checkDriverAvailability(int searchRadius) {
        AtomicLong i = new AtomicLong();
        Instant end = Instant.now()
                .plus(OP_DURATION.multipliedBy(searchRadius));
        while (Instant.now().compareTo(end) <= 0) {
            i.incrementAndGet();
        }
        // Every other minute this will artificially create make requests in eu-north region slow
        // this is just for demonstration purposes to show how performance impacts show up in the
        // flamegraph
        boolean force_mutex_lock = Instant.now().atZone(ZoneOffset.UTC).getMinute() % 2 == 0;
        if (System.getenv("REGION").equals("eu-north") && force_mutex_lock) {
            mutexLock(searchRadius);
        }
        // Metric
        searchCounterMetric.labels("appjava1", "checkDriverAvailability").inc();
    }

    private void mutexLock(int searchRadius) {
        AtomicLong i = new AtomicLong();
        Instant end = Instant.now()
                .plus(OP_DURATION.multipliedBy(30L * searchRadius));
        while (Instant.now().compareTo(end) <= 0) {
             i.incrementAndGet();
        }
    }

}
