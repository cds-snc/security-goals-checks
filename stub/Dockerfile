FROM alpine:3.9 as builder
RUN apk add --no-cache crystal=0.27.0-r0 shards=0.8.1-r0 libc-dev=0.7.1-r0 zlib-dev=1.2.11-r1 openssl-dev=1.1.1b-r1 && rm -rf /var/cache/apk/*
WORKDIR /src
COPY . .
RUN crystal build --release --static src/run.cr -o /src/run

FROM scratch

WORKDIR /app
COPY --from=builder /src/run /app/run

ENTRYPOINT ["/app/run"]
