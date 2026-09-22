FROM golang:1.27.1@sha256:3680233e3204827fbdc66088528ae6d4b3d034f51d03a99d454f6de034888244

WORKDIR /go/src/app

COPY main.go ./main.go

RUN go mod init github.com/pyroscope-io/pyroscope/examples/golang-pull/static
RUN go get -d ./
RUN go build -o main .

RUN adduser --disabled-password --gecos --quiet pyroscope
USER pyroscope

CMD ["./main"]
