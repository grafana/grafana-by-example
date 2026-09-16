FROM clickhouse/clickhouse-server@sha256:5a55fb7517cbba97a99b8676a748fd13e4709049a4d1f5d5be5c20695da4c91b

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim unzip wget curl net-tools iputils-ping ca-certificates \
    syslog-ng
