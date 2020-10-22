FROM nginx:1.19.1 as base

# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
ARG TIME_ZONE

RUN sed -i -E 's/listen[[:space:]]+[[:digit:]]+/listen 8080/' /etc/nginx/conf.d/default.conf

RUN mkdir -p /opt/var/cache/nginx && \
    cp -a --parents /usr/lib/nginx /opt && \
    cp -a --parents /usr/share/nginx /opt && \
    cp -a --parents /var/log/nginx /opt && \
#    cp -aL --parents /var/run /opt && \
    cp -a --parents /etc/nginx /opt && \
    cp -a --parents /etc/passwd /opt && \
    cp -a --parents /etc/group /opt && \
    cp -a --parents /usr/sbin/nginx /opt && \
    cp -a --parents /usr/sbin/nginx-debug /opt && \
    cp -a --parents /lib/x86_64-linux-gnu/ld-* /opt && \
    cp -a --parents /lib/x86_64-linux-gnu/libpcre.so.* /opt && \
    cp -a --parents /lib/x86_64-linux-gnu/libz.so.* /opt && \
    cp -a --parents /lib/x86_64-linux-gnu/libc* /opt && \
    cp -a --parents /lib/x86_64-linux-gnu/libdl* /opt && \
    cp -a --parents /lib/x86_64-linux-gnu/libpthread* /opt && \
    cp -a --parents /lib/x86_64-linux-gnu/libcrypt* /opt && \
    cp -a --parents /usr/lib/x86_64-linux-gnu/libssl.so.* /opt && \
    cp -a --parents /usr/lib/x86_64-linux-gnu/libcrypto.so.* /opt && \
    cp /usr/share/zoneinfo/${TIME_ZONE:-ROC} /opt/etc/localtime

RUN ls -alR /opt

FROM node:lts-buster as builder

ARG GRAPHCMS_ENDPOINT
ARG AUTH_TOKEN

WORKDIR /app

ADD package.json .

RUN yarn install

ADD . .

RUN yarn gridsome build


FROM gcr.io/distroless/base-debian10

COPY --from=base /opt /
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 8080

ENTRYPOINT ["nginx", "-g", "daemon off;"]

