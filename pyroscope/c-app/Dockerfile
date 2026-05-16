FROM ubuntu:latest@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64 

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
