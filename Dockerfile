FROM golang:1.14-alpine3.13 as builder

# vendor flags conflict with `go get`
# so we fetch golint before running make
# and setting the env variable
RUN apk update && apk add git make bash build-base gcc bc
RUN go get -u golang.org/x/lint/golint

RUN mkdir -p /go/src/github.com/Netflix/chaosmonkey
WORKDIR /go/src/github.com/Netflix/chaosmonkey
ADD ./ /go/src/github.com/Netflix/chaosmonkey


RUN make all

FROM alpine:3.17
COPY --from=builder /go/src/github.com/Netflix/chaosmonkey/build/chaosmonkey /opt/chaosmonkey/bin/chaosmonkey
COPY --from-builder /go/src/github.com/Netflix/chaosmonkey/docs/chaosmonkey-terminate.sh /opt/chaosmonkey/bin/chaosmonkey-terminate.sh
COPY --from-builder /go/src/github.com/Netflix/chaosmonkey/docs/chaosmonkey.toml /etc/chaosmonkey.toml

WORKDIR /opt/chaosmonkey/bin

CMD ["/opt/chaosmonkey/bin/chaosmonkey"]
