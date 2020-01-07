FROM golang AS builder

ARG ES_VERSION=7.5.1

RUN set -ex

RUN apt-get update && apt-get install -y libpcap-dev

WORKDIR /go/src/github.com/elastic/

RUN git clone --depth 1 --branch v$ES_VERSION https://github.com/elastic/beats.git

WORKDIR /go/src/github.com/elastic/beats/packetbeat

RUN go build -v -x

FROM debian:buster-slim

RUN apt-get update && apt-get install -y libpcap0.8

COPY --from=builder /go/src/github.com/elastic/beats/packetbeat/packetbeat /beat/packbeat
COPY --from=builder /go/src/github.com/elastic/beats/packetbeat/packetbeat.yml /beat/packetbeat.yml
