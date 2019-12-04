FROM crystallang/crystal:0.31.1 as builder

WORKDIR /app
COPY ./shard.yml /app/
RUN shards install

COPY . /app/
RUN shards build --production -v

FROM ubuntu:xenial
RUN \
  apt-get update && \
  apt-get install -y \
    ca-certificates \
    libssl1.0.0 \
    libssl-dev \
    libevent-2.0.5 \
    libxml2-dev \
    libyaml-dev \
    libgmp-dev \
    libevent-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
WORKDIR /
COPY --from=builder /app/bin/medup .

ENTRYPOINT ["/medup"]
