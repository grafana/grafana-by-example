FROM ubuntu:latest@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64

ENV HOME_DIR="/home/test"
RUN mkdir ${HOME_DIR}

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim unzip wget curl net-tools iputils-ping ca-certificates \
    syslog-ng

WORKDIR ${HOME_DIR}

COPY syslog-ng/entrypoint.sh ${HOME_DIR}
COPY syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf 

CMD ${HOME_DIR}/entrypoint.sh
