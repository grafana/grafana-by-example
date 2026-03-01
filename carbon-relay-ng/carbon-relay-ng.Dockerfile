FROM ubuntu:latest@sha256:d1e2e92c075e5ca139d51a140fff46f84315c0fdce203eab2807c7e495eff4f9

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim unzip wget curl netcat net-tools iputils-ping ca-certificates

ENV SRC_DIR=.
ENV SW_DIR=/carbon-relay-ng

#FROM grafana/carbon-relay-ng:latest as carbon-relay

COPY --from=grafana/carbon-relay-ng:latest@sha256:1fbbc1c1baceed51f1828dd94e0c757e921a28b7e3fcb90da3664df0ea4caa5b          /bin/carbon-relay-ng /bin
#COPY $SRC_DIR/carbon-relay-ng-configured.ini        /etc/carbon-relay-ng/carbon-relay-ng.ini 
COPY $SRC_DIR/storage-schemas.conf                  /etc/carbon-relay-ng/
COPY $SRC_DIR/storage-aggregation.conf              /etc/carbon-relay-ng/


WORKDIR ${SW_DIR}
COPY ${SRC_DIR}/* ${SW_DIR}

#CMD sleep 3600
#ENTRYPOINT [ "sleep", "3600" ]
ENTRYPOINT [ "./ctl.sh", "start" ]
#CMD ./ctl.sh configure && ./ctl.sh start && ./ctl.sh send-metrics
