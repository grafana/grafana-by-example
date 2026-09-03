FROM ubuntu:latest@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

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
