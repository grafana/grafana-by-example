FROM clickhouse/clickhouse-server@sha256:a73b5c0fb6f88e02357aead0906ad53882b07e4d202327489798844ba745e64d

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim unzip wget curl net-tools iputils-ping ca-certificates \
    syslog-ng
