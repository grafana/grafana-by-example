FROM clickhouse/clickhouse-server@sha256:402d385614cb9ba0214b5d9262e4c9cfe3d9fdc832bbbaca20d62a233eb0d9c4

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim unzip wget curl net-tools iputils-ping ca-certificates \
    syslog-ng
