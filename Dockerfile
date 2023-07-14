FROM alpine:3.9 AS build

ARG PCRE_VERSION="8.43"
ARG PCRE_CHECKSUM="0b8e7465dc5e98c757cc3650a20a7843ee4c3edf50aaf60bb33fd879690d2c73"

ARG ZLIB_VERSION="1.2.11"
ARG ZLIB_CHECKSUM="c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1"

ARG NGINX_VERSION="1.15.9"
ARG NGINX_CHECKSUM="e4cfba989bba614cd53f3f406ac6da9f05977d6b1296e5d20a299f10c2d7ae43"
ARG NGINX_CONFIG="\
    --sbin-path=/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/tmp/nginx.pid \
    --http-log-path=/dev/stdout \
    --error-log-path=/dev/stdout \
    --http-client-body-temp-path=/tmp/client_temp \
    --http-proxy-temp-path=/tmp/proxy_temp \
    --http-fastcgi-temp-path=/tmp/fastcgi_temp \
    --http-uwsgi-temp-path=/tmp/uwsgi_temp \
    --http-scgi-temp-path=/tmp/scgi_temp \
    --with-pcre=/tmp/pcre-$PCRE_VERSION \
    --with-zlib=/tmp/zlib-$ZLIB_VERSION \
    --with-file-aio \
    --with-http_v2_module \
    --with-http_stub_status_module \
    --with-stream \
    --with-threads"

ADD https://ftp.exim.org/pub/pcre/pcre-$PCRE_VERSION.tar.gz /tmp/pcre.tar.gz
ADD https://www.zlib.net/fossils/zlib-$ZLIB_VERSION.tar.gz /tmp/zlib.tar.gz
ADD https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz /tmp/nginx.tar.gz

RUN cd /tmp && \
    if [ "$PCRE_CHECKSUM" != "$(sha256sum /tmp/pcre.tar.gz | awk '{print $1}')" ]; then exit 1; fi && \
    tar xf /tmp/pcre.tar.gz && \
    if [ "$ZLIB_CHECKSUM" != "$(sha256sum /tmp/zlib.tar.gz | awk '{print $1}')" ]; then exit 1; fi && \
    tar xf /tmp/zlib.tar.gz && \
    if [ "$NGINX_CHECKSUM" != "$(sha256sum /tmp/nginx.tar.gz | awk '{print $1}')" ]; then exit 1; fi && \
    tar xf /tmp/nginx.tar.gz && \
    mv /tmp/nginx-$NGINX_VERSION /tmp/nginx

RUN cd /tmp/nginx && \
    apk add git gcc g++ perl make linux-headers upx binutils && \
    ./configure $NGINX_CONFIG && \
    make && \
    strip /tmp/nginx/objs/nginx && \
    upx -9 /tmp/nginx/objs/nginx

FROM scratch

COPY /rootfs /

COPY --from=build /lib/ld-musl-* \
                  /lib/
COPY --from=build /tmp/nginx/objs/nginx /nginx

STOPSIGNAL SIGTERM

ENTRYPOINT ["/nginx", "-g", "daemon off;"]
