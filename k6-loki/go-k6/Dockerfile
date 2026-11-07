FROM golang:latest@sha256:e519d3b0a5b285e5aa53ab9eef02bc6bbb9cb04608389b743a136a9ce75f0d1e

ENV HOME_DIR="/home/test"
RUN mkdir ${HOME_DIR}
WORKDIR ${HOME_DIR}

RUN go install go.k6.io/xk6/cmd/xk6@latest 
RUN xk6 build --with github.com/grafana/xk6-loki@latest

CMD /bin/bash
