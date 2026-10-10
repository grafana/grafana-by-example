FROM ubuntu:latest@sha256:f144425ff09be612d6d9ad965196e9cdc23dae1f42110a8a11a3e9a8198759f7

ENV HOME_DIR="/home/test"
RUN mkdir ${HOME_DIR}

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl iputils-ping net-tools unzip vim wget    \
    apt-transport-https ca-certificates dirmngr gnupg

# ClickHouse https://clickhouse.com/docs/en/getting-started/install/
RUN apt-get update && apt-get install -y --no-install-recommends

#RUN python3 python3-pip \
 #   && pip3 install clickhouse_driver
#     clickhouse-client clickhouse-server

WORKDIR ${HOME_DIR}

CMD /bin/bash
