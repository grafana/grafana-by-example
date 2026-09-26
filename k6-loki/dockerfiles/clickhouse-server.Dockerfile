FROM clickhouse/clickhouse-server@sha256:12b16e744f91d8228705e136bd2b0ab14c939c87ff82443090279b65255c50c1

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim unzip wget curl net-tools iputils-ping ca-certificates \
    syslog-ng
