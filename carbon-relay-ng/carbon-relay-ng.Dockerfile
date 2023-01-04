FROM ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim unzip wget curl netcat net-tools iputils-ping ca-certificates

ENV SRC_DIR=.
ENV SW_DIR=/carbon-relay-ng

#FROM grafana/carbon-relay-ng:latest as carbon-relay

COPY --from=grafana/carbon-relay-ng:latest          /bin/carbon-relay-ng /bin
#COPY $SRC_DIR/carbon-relay-ng-configured.ini        /etc/carbon-relay-ng/carbon-relay-ng.ini 
COPY $SRC_DIR/storage-schemas.conf                  /etc/carbon-relay-ng/
COPY $SRC_DIR/storage-aggregation.conf              /etc/carbon-relay-ng/


WORKDIR ${SW_DIR}
COPY ${SRC_DIR}/* ${SW_DIR}

#CMD sleep 3600
#ENTRYPOINT [ "sleep", "3600" ]
ENTRYPOINT [ "./ctl.sh", "start" ]
#CMD ./ctl.sh configure && ./ctl.sh start && ./ctl.sh send-metrics
