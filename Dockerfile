FROM golang:1.12 as build

ENV GO111MODULE on
ENV GOPROXY "https://goproxy.io"

WORKDIR /opt
RUN mkdir etcdviewer
ADD . /opt/etcdviewer
WORKDIR /opt/etcdviewer/src/etcdviewer

RUN go mod download \
    && go build -o etcdviewer.bin main.go


FROM alpine:3.10

ENV HOST="0.0.0.0"
ENV PORT="8080"

# RUN apk add --no-cache ca-certificates

RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

WORKDIR /opt/etcdviewer
COPY --from=build /opt/etcdviewer/src/etcdviewer/etcdviewer.bin .
ADD assets assets

EXPOSE ${PORT}

ENTRYPOINT ./etcdviewer.bin -h $HOST -p $PORT