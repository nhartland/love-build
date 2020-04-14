FROM alpine:3.11.5
# Install general dependencies
RUN  apk add --no-cache zip git luarocks5.1

# Copy and setup entrypoint
COPY build.sh /love-build/build.sh
ENTRYPOINT ["/love-build/build.sh"]
