FROM debian:buster-slim

# Install general dependencies
RUN apt-get install -y lua5.1 build-essential libreadline-dev

# Fetch and build luarocks-3
RUN wget https://luarocks.org/releases/luarocks-3.3.1.tar.gz && tar zxpf luarocks-3.3.1.tar.gz
RUN cd luarocks-3.3.1 && ./configure && make && make install

# Copy and setup entrypoint
COPY build.sh /love-build/build.sh
ENTRYPOINT ["/love-build/build.sh"]
