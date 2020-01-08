FROM golang:1.13.5-alpine3.10 AS build

COPY hello-world.go .

RUN go build hello-world.go

FROM alpine

COPY --from=build /go/hello-world /hello

ENTRYPOINT ["/hello"] 