FROM golang:1.27.2@sha256:820153096fda4de6ac1b7194d12e416b7dd8f4e9a33d17e0345b111b945162d8

WORKDIR /go/src/app

COPY main.go ./main.go

RUN go mod init github.com/pyroscope-io/pyroscope/examples/golang-pull/static
RUN go get -d ./
RUN go build -o main .

RUN adduser --disabled-password --gecos --quiet pyroscope
USER pyroscope

CMD ["./main"]
