# Build layer
FROM crystallang/crystal:1.0.0-alpine as build

# Install development tools required for building
RUN apk --no-cache add \
    ruby-rake \
    ruby-json

# Initialoze the working directory
WORKDIR /app

# Cache install package dependicies
COPY ./shard.* /app/
RUN shards install --production -v

# Build the app
COPY . /app/
RUN rake build:static

# Runtime layer
FROM scratch as runtime
# Put the binary in the ROOT folder
WORKDIR /
# Don't run as root
USER 1001

# Copy/install required assets like CA certificates
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/cert.pem
COPY --from=build /app/_output/medup .

ENTRYPOINT ["/medup"]
