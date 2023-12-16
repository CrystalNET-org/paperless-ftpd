# Use Alpine Linux
ARG ALPINE_VERSION=edge
FROM alpine:$ALPINE_VERSION as builder

LABEL author="Lukas Wingerberg"
LABEL author_email="h@xx0r.eu"
LABEL github_url="https://github.com/psych0d0g/pure-ftpd"

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk --update-cache --no-cache upgrade && \
    apk add --update-cache --no-cache shadow openssl less bash tzdata git make g++ automake autoconf libpq-dev mariadb-connector-c-dev libsodium-dev musl-dev go && \
    rm -rf /var/cache/apk/*

RUN mkdir -p /temp/build /temp/out && \
    cd /temp/build && \
    git clone https://github.com/jedisct1/pure-ftpd.git && \
    cd pure-ftpd && \
    ./autogen.sh && \
    ./configure --with-pgsql --with-mysql --with-puredb --with-nonroot --with-virtualchroot --with-altlog --without-inetd --without-shadow --without-usernames --prefix=/opt/pureftpd && \
    make install-strip -j8 && \
    ls /opt/pureftpd && \
    cd /temp/build

FROM alpine:$ALPINE_VERSION as image
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk --update-cache --no-cache upgrade && \
    apk add --update-cache --no-cache bash libpq mariadb-connector-c libsodium && \
    rm -rf /var/cache/apk/*

COPY --from=builder /opt /opt
ADD rootfs /
RUN ls /opt/pureftpd/sbin

ENTRYPOINT [ "/entrypoint.sh" ]