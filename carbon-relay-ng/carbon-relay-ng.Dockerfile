FROM ubuntu:latest@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim unzip wget curl netcat net-tools iputils-ping ca-certificates

ENV SRC_DIR=.
ENV SW_DIR=/carbon-relay-ng

#FROM grafana/carbon-relay-ng:latest as carbon-relay

COPY --from=grafana/carbon-relay-ng:latest@sha256:c3ab39791140e512f7754a0bcd2276a2df4ead22688a4cb42957c2c79a793a0d          /bin/carbon-relay-ng /bin
#COPY $SRC_DIR/carbon-relay-ng-configured.ini        /etc/carbon-relay-ng/carbon-relay-ng.ini 
COPY $SRC_DIR/storage-schemas.conf                  /etc/carbon-relay-ng/
COPY $SRC_DIR/storage-aggregation.conf              /etc/carbon-relay-ng/


WORKDIR ${SW_DIR}
COPY ${SRC_DIR}/* ${SW_DIR}

#CMD sleep 3600
#ENTRYPOINT [ "sleep", "3600" ]
ENTRYPOINT [ "./ctl.sh", "start" ]
#CMD ./ctl.sh configure && ./ctl.sh start && ./ctl.sh send-metrics
