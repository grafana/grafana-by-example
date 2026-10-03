FROM golang:latest@sha256:e0174e51e81218523251d85d248a90d24c3d5e81543b4f07a5d66229397db190

ENV HOME_DIR="/home/test"
RUN mkdir ${HOME_DIR}
WORKDIR ${HOME_DIR}

RUN go install go.k6.io/xk6/cmd/xk6@latest 
RUN xk6 build --with github.com/grafana/xk6-loki@latest

CMD /bin/bash
