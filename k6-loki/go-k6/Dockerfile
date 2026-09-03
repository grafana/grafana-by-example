FROM golang:latest@sha256:512690a5660563b57d37ecc31129e7f136e831db2aed24a1dbeb8ad7380dc0fa

ENV HOME_DIR="/home/test"
RUN mkdir ${HOME_DIR}
WORKDIR ${HOME_DIR}

RUN go install go.k6.io/xk6/cmd/xk6@latest 
RUN xk6 build --with github.com/grafana/xk6-loki@latest

CMD /bin/bash
