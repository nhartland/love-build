FROM archlinux/base:latest

RUN pacman -Syy && \
  # Install love-release
  yes | pacman -S \
    gcc \
    git \
    libzip \
    luarocks && \
  luarocks install lua-libzip && \
  luarocks install love-release && \
  luarocks install loverocks && \
  # Install luaunit
  luarocks install luaunit 

ENV PATH="$PATH:~/bin"
