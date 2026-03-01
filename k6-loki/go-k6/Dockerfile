FROM golang:latest@sha256:9edf71320ef8a791c4c33ec79f90496d641f306a91fb112d3d060d5c1cee4e20

ENV HOME_DIR="/home/test"
RUN mkdir ${HOME_DIR}
WORKDIR ${HOME_DIR}

RUN go install go.k6.io/xk6/cmd/xk6@latest 
RUN xk6 build --with github.com/grafana/xk6-loki@latest

CMD /bin/bash
