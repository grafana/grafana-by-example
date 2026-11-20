FROM golang:latest@sha256:205c7636d74e0ffbe3d007162df7d74f859f5a8c8322dfb9f907977686c126cf

ENV HOME_DIR="/home/test"
RUN mkdir ${HOME_DIR}
WORKDIR ${HOME_DIR}

RUN go install go.k6.io/xk6/cmd/xk6@latest 
RUN xk6 build --with github.com/grafana/xk6-loki@latest

CMD /bin/bash
