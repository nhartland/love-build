FROM alpine:3.11.5
# Install general dependencies
RUN  apk add --no-cache zip git luarocks5.1
RUN luarocks-5.1 install etlua
RUN luarocks-5.1 install loverocks

# Copy and setup entrypoint
COPY build.sh /love-build/build.sh
COPY rockspec-template.lua /love-build/rockspec-template.lua
ENTRYPOINT ["/love-build/build.sh"]
