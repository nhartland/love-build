FROM alpine:latest
COPY build.sh /build.sh
ENTRYPOINT ["/build.sh"]
