FROM golang:latest@sha256:313faae491b410a35402c05d35e7518ae99103d957308e940e1ae2cfa0aac29b

ENV HOME_DIR="/home/test"
RUN mkdir ${HOME_DIR}
WORKDIR ${HOME_DIR}

RUN go install go.k6.io/xk6/cmd/xk6@latest 
RUN xk6 build --with github.com/grafana/xk6-loki@latest

CMD /bin/bash
