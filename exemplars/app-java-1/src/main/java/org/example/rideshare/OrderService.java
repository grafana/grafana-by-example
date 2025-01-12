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

// OTEL
import io.opentelemetry.api.OpenTelemetry; 
import io.opentelemetry.sdk.OpenTelemetrySdk; 
import io.opentelemetry.sdk.metrics.export.MetricReader;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.api.metrics.Meter;
import io.opentelemetry.api.metrics.LongCounter;
import io.opentelemetry.api.GlobalOpenTelemetry; 


// References
// https://github.com/prometheus/client_java/tree/main/examples/example-exemplars-tail-sampling

@Service
public class OrderService {
    public HTTPServer promServer;
    public Counter     searchCounterMetricProm;
    public io.opentelemetry.api.metrics.LongCounter m1;

    public OrderService() {
        // Create a custom Appliation Metric
        try {
            // Prometheues Metric
            searchCounterMetricProm = Counter
                .build()
                .name("appsearches")
                .help("Count of Searches")
                .labelNames("job", "type")
                .register();
            promServer = new HTTPServer( 8002 );

            // Otel Metric
            Meter meter = GlobalOpenTelemetry.getMeter("rideshare");
            m1 = meter
                .counterBuilder("app.searches.otel")
                .setDescription("Count of Searches")
                .setUnit("events")
                .build();
        } catch( Exception e ) {
            e.printStackTrace();
        }
        

        //     implementation platform("io.opentelemetry:opentelemetry-bom")
       
        
        // Attempt to rename trace_id to traceID - TBD
        //PrometheusRegistry pr1 = PrometheusRegistry.defaultRegistry;
        //pr1.config().commonTags("trace_id", "traceID");
        //CollectorRegistry defaultRegistry = CollectorRegistry.defaultRegistry;
        //defaultRegistry.config().commonTags("trace_id", "traceID");
    }

    //Meter meter = GlobalOpenTelemetry.getMeter("my-java-app");
    //LongCounter counter = meter.counterBuilder("requests_processed").build();
    //counter.add(1);

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
        searchCounterMetricProm.labels("appjava1", "findNearestVehicle").inc();
        m1.add(1);
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
        searchCounterMetricProm.labels("appjava1", "checkDriverAvailability").inc();
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
