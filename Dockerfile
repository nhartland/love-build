FROM debian:buster-slim

# Install general dependencies
RUN apt update -q -y && \
    apt install -q -y lua5.1 liblua5.1-0-dev build-essential libreadline-dev wget zip

# Fetch and build luarocks
ARG LUAROCKS_VERSION=3.11.1
RUN wget https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz && \
    tar zxpf luarocks-${LUAROCKS_VERSION}.tar.gz && \
    rm luarocks-${LUAROCKS_VERSION}.tar.gz 
RUN cd luarocks-${LUAROCKS_VERSION} && \
    ./configure && \
    make && make install

# Copy and setup entrypoint
COPY build.sh /love-build/build.sh
COPY module_loader.lua /love-build/module_loader.lua
ENTRYPOINT ["/love-build/build.sh"]

# docker build . -t love-build --no-cache
# docker run -it -v./tests:/tmp/tests -w /love-build --entrypoint /bin/bash love-build
# INPUT_APP_NAME=hello_word INPUT_LOVE_VERSION=11.5 INPUT_SOURCE_DIR=/tmp/tests/hello_world INPUT_RESULT_DIR=/tmp/result GITHUB_OUTPUT=/tmp/out /love-build/build.sh