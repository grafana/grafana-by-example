FROM ubuntu:latest@sha256:da6fc2be547864451aa253836dd926da33623312df4a9a243e35dc877c378a78

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
