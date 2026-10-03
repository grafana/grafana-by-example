FROM golang:1.21.3@sha256:b113af1e8b06f06a18ad41a6b331646dff587d7a4cf740f4852d16c49ed8ad73

WORKDIR /go/src/app

COPY main.go ./main.go

RUN go mod init github.com/pyroscope-io/pyroscope/examples/golang-pull/static
RUN go get -d ./
RUN go build -o main .

RUN adduser --disabled-password --gecos --quiet pyroscope
USER pyroscope

CMD ["./main"]
