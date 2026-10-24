FROM clickhouse/clickhouse-server@sha256:b2bfa4d8399ee9973868cc5c1754cb506a6f4b86fbddc41010cc090beb55c85e

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim unzip wget curl net-tools iputils-ping ca-certificates \
    syslog-ng
