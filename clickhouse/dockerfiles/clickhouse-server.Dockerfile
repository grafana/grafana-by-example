FROM clickhouse/clickhouse-server@sha256:5ff094c939ac8da80de4bd449e13b8b762a04eeaac73ba47bdf0aafe992033a3

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim unzip wget curl net-tools iputils-ping ca-certificates \
    syslog-ng
