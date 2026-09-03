FROM clickhouse/clickhouse-server@sha256:fa394da808cc53f76d0344429421d6c422a6ee85fe7450135c0e3cff4df9bcbb

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim unzip wget curl net-tools iputils-ping ca-certificates \
    syslog-ng
