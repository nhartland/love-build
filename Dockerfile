FROM debian:buster-slim

# Install general dependencies
RUN apt-get update -q -y 
RUN apt-get install -q -y lua5.1 \
                          liblua5.1-0-dev \
                          build-essential \
                          libreadline-dev \
                          wget \
                          zip

# Fetch and build luarocks-3.3.1
RUN wget https://luarocks.org/releases/luarocks-3.3.1.tar.gz && \
    tar zxpf luarocks-3.3.1.tar.gz
RUN cd luarocks-3.3.1 && \
    ./configure && \
    make && make install

# Copy and setup entrypoint
COPY build.sh /love-build/build.sh
COPY module_loader.lua /love-build/module_loader.lua
ENTRYPOINT ["/love-build/build.sh"]
