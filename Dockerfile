FROM alpine:latest
# Install general dependencies
RUN  apk add --no-cache zip git luarocks5.1
RUN luarocks-5.1 install loverocks

# Copy and setup entrypoint
COPY build.sh /build.sh
ENTRYPOINT ["/build.sh"]
