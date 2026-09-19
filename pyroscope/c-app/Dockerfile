FROM ubuntu:latest@sha256:da6fc2be547864451aa253836dd926da33623312df4a9a243e35dc877c378a78 

# Update OS and add essentials
RUN apt-get -y update && apt-get -y upgrade && \ 
        apt-get -y install build-essential && \
        apt-get -y install wget gpg vim \
        libc6-dbg

# Install Grafana Alloy
RUN mkdir -p /etc/apt/keyrings/ && \
    wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list

WORKDIR /usr/src/app

# Build the App
COPY Makefile ./
COPY find-prime.cpp ./
RUN make

#ENTRYPOINT [ "sleep", "3600" ]
ENTRYPOINT [ "/usr/src/app/find-prime" ]
