FROM clickhouse/clickhouse-server@sha256:630693b4a8bce41954fe497ed371918aefe99434139d2da5786276459722fbb6

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim unzip wget curl net-tools iputils-ping ca-certificates \
    syslog-ng
