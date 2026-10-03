FROM ubuntu:latest@sha256:3595d7fc4286a33fad0fd853a4063e654287a9c3787437d7937c94ca3f7a804e

ENV HOME_DIR="/home/test"
RUN mkdir ${HOME_DIR}

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim unzip wget curl net-tools iputils-ping ca-certificates \
    syslog-ng

WORKDIR ${HOME_DIR}

COPY syslog-ng/entrypoint.sh ${HOME_DIR}
COPY syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf 

CMD ${HOME_DIR}/entrypoint.sh
