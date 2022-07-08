# docker.io/miry/medup

# Build layer
ARG CRYSTAL_VERSION=1.5.0
ARG USER=1001

FROM docker.io/crystallang/crystal:${CRYSTAL_VERSION}-alpine as build

# Install development tools required for building
RUN apk --no-cache add \
    ruby-rake \
    ruby-json \
 && mkdir /app \
 && chown 1001:1001 /app

USER ${USER}

# Initialoze the working directory
WORKDIR /app

# Cache install package dependicies
COPY ./shard.* /app/
RUN shards install --production -v

COPY ./lib/*.cr /app/lib/

# Build the app
COPY . /app/
RUN rake build:static \
 && chmod 555 /app/_output/medup

# Runtime layer
FROM scratch as runtime

USER ${USER}

WORKDIR /

# Copy/install required assets like CA certificates
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/cert.pem
COPY --from=build /app/_output/medup .

ENTRYPOINT ["/medup"]
