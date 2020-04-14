FROM debian:buster-slim
# Install general dependencies
RUN apt install luarocks

# Copy and setup entrypoint
COPY build.sh /love-build/build.sh
ENTRYPOINT ["/love-build/build.sh"]
