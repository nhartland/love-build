FROM alpine:latest
RUN  apk add --update zip
COPY build.sh /build.sh
ENTRYPOINT ["/build.sh"]
