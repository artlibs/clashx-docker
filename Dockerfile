FROM alpine:latest

LABEL org.opencontainers.image.authors="i36.lib@gmail.com"

ARG ARCH_TYPE=unsupport
ARG PREMIUM=unsupport

WORKDIR /var/app

COPY webui webui
COPY Country.mmdb .
COPY ${ARCH_TYPE}/clash${PREMIUM} /usr/local/bin/clash
COPY reload.sh /usr/local/bin/reload.sh
COPY entry.sh /usr/local/bin/entry.sh

RUN chmod +x /usr/local/bin/clash \
    /usr/local/bin/reload.sh \
    /usr/local/bin/entry.sh \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update && apk add --no-cache curl shadow

EXPOSE 7890 9090
VOLUME ["/config"]

ENTRYPOINT ["/bin/sh", "/usr/local/bin/entry.sh"] 
