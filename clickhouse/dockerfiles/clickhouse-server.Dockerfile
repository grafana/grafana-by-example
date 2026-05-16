FROM clickhouse/clickhouse-server@sha256:6d8f358747b59f7db044749eaf951e828e75cc16f9c487f855b114272c44b82c

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim unzip wget curl net-tools iputils-ping ca-certificates \
    syslog-ng
