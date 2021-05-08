FROM crystallang/crystal:1.0.0-alpine as builder

WORKDIR /app
COPY ./shard.yml ./shard.lock /app/
RUN shards install --production -v

COPY . /app/
RUN shards build --production --static --release --no-debug -v

FROM scratch
WORKDIR /
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/cert.pem
COPY --from=builder /app/bin/medup .

ENTRYPOINT ["/medup"]
