FROM crystallang/crystal:1.0.0-alpine as builder

WORKDIR /app
COPY ./shard.yml ./shard.lock /app/
RUN shards install --production -v

COPY . /app/
RUN shards build --production -v --static

FROM alpine:latest
WORKDIR /
COPY --from=builder /app/bin/medup .

ENTRYPOINT ["/medup"]
