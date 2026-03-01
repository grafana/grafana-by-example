FROM ubuntu:latest@sha256:d1e2e92c075e5ca139d51a140fff46f84315c0fdce203eab2807c7e495eff4f9

ENV HOME_DIR="/home/test"
RUN mkdir ${HOME_DIR}

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl iputils-ping net-tools unzip vim wget    \
    apt-transport-https ca-certificates dirmngr gnupg

# ClickHouse https://clickhouse.com/docs/en/getting-started/install/
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8919F6BD2B48D754 \
    && echo "deb https://packages.clickhouse.com/deb stable main" \
        | tee /etc/apt/sources.list.d/clickhouse.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    clickhouse-client

#RUN python3 python3-pip \
 #   && pip3 install clickhouse_driver
#     clickhouse-client clickhouse-server

WORKDIR ${HOME_DIR}

CMD /bin/bash
