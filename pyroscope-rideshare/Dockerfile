FROM --platform=$BUILDPLATFORM openjdk:17-slim-bullseye as builder

WORKDIR /opt/app

RUN apt-get update && apt-get install ca-certificates -y && update-ca-certificates 



COPY gradlew .
COPY gradle gradle
RUN ./gradlew

COPY build.gradle.kts settings.gradle.kts ./
RUN ./gradlew dependencies --no-daemon

COPY src src
RUN ./gradlew assemble --no-daemon


FROM  openjdk:17-slim-bullseye

RUN apt-get update && apt-get install ca-certificates -y && update-ca-certificates

#ENV PYROSCOPE_APPLICATION_NAME=rideshare.java.ryder
ENV PYROSCOPE_FORMAT=jfr
ENV PYROSCOPE_PROFILING_INTERVAL=10ms
ENV PYROSCOPE_PROFILER_EVENT=itimer
ENV PYROSCOPE_PROFILER_LOCK=10ms
ENV PYROSCOPE_PROFILER_ALLOC=512k
ENV PYROSCOPE_UPLOAD_INTERVAL=15s
ENV PYROSCOPE_LOG_LEVEL=debug
#ENV PYROSCOPE_SERVER_ADDRESS=http://localhost:4040


ENV OTEL_PYROSCOPE_ADD_PROFILE_URL=false
ENV OTEL_PYROSCOPE_ADD_PROFILE_BASELINE_URL=false
ENV OTEL_PYROSCOPE_START_PROFILING=true

# Add the pyroscope-otel.jar as an extension to the OTEL Java Agent
ENV OTEL_JAVAAGENT_EXTENSIONS=./pyroscope-otel.jar

COPY --from=builder /opt/app/build/libs/rideshare-1.0-SNAPSHOT.jar /opt/app/build/libs/rideshare-1.0-SNAPSHOT.jar

WORKDIR /opt/app

# Java OTEL Agent and Pyroscope-otel
ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v1.17.0/opentelemetry-javaagent.jar opentelemetry-javaagent.jar
ADD https://repo1.maven.org/maven2/io/pyroscope/otel/0.11.0/otel-0.11.0.jar pyroscope-otel.jar

# Needed only if manual instrumentation is used, added using -javaagent:
ADD https://repo1.maven.org/maven2/io/pyroscope/agent/0.16.0/agent-0.16.0.jar pyroscope.jar

#ADD https://repo1.maven.org/maven2/io/pyroscope/otel/0.10.1/otel-0.10.1.jar pyroscope-otel.jar

EXPOSE 5000

CMD ["java", "-Dserver.port=5000", "-javaagent:./pyroscope.jar", "-javaagent:./opentelemetry-javaagent.jar", "-jar", "./build/libs/rideshare-1.0-SNAPSHOT.jar" ]
#CMD ["java", "-Dserver.port=5000", "-javaagent:./opentelemetry-javaagent.jar", "-jar", "./build/libs/rideshare-1.0-SNAPSHOT.jar" ]
# Validate if traces are linked to profiles: { .pyroscope.profile.id != "" }