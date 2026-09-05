FROM golang:1.27.1@sha256:512690a5660563b57d37ecc31129e7f136e831db2aed24a1dbeb8ad7380dc0fa

WORKDIR /go/src/app

COPY main.go ./main.go

RUN go mod init github.com/pyroscope-io/pyroscope/examples/golang-pull/static
RUN go get -d ./
RUN go build -o main .

RUN adduser --disabled-password --gecos --quiet pyroscope
USER pyroscope

CMD ["./main"]
