FROM ubuntu:latest@sha256:065aa8626841f16057b78b027b464cd59c4fac36c204c72dcbf48d66f5fa8a96 

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
