FROM ubuntu:latest@sha256:513c074113a871b51a8d16ab445c88779d6452d937a164fb5cc479f32668a41d

ENV HOME_DIR="/home/test"
RUN mkdir ${HOME_DIR}

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim unzip wget curl net-tools iputils-ping ca-certificates \
    syslog-ng

WORKDIR ${HOME_DIR}

COPY syslog-ng/entrypoint.sh ${HOME_DIR}
COPY syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf 

CMD ${HOME_DIR}/entrypoint.sh
