FROM clickhouse/clickhouse-server@sha256:b32b9a19fadc2750880ff059dcf074907b1506922b5480fb40abd65efc48fb29

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim unzip wget curl net-tools iputils-ping ca-certificates \
    syslog-ng
