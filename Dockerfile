FROM debian:buster-slim
# Install general dependencies
RUN apt install luarocks-3

# Copy and setup entrypoint
COPY build.sh /love-build/build.sh
ENTRYPOINT ["/love-build/build.sh"]
