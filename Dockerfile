# renovate: datasource=github-releases depName=CrystalNET-org/pure-ftpd-paperless-dbauth versioning=loose
ARG PAPERLESS_AUTH_VERSION=0.0.9

FROM harbor.crystalnet.org/dockerhub-proxy/alpine:3.20 AS builder
ARG TARGETARCH
ARG PAPERLESS_AUTH_VERSION

LABEL author="Lukas Wingerberg"
LABEL author_email="h@xx0r.eu"
LABEL github_url="https://github.com/CrystalNET-org/containers/tree/main/paperless-ftpd"

RUN echo "I am building for ${TARGETARCH} and with auth binary release: ${PAPERLESS_AUTH_VERSION}"

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk --update-cache --no-cache upgrade && \
    apk add --update-cache --no-cache curl openssl less bash tzdata git make g++ automake autoconf libsodium-dev musl-dev go && \
    rm -rf /var/cache/apk/*

RUN mkdir -p /temp/build /temp/out && \
    cd /temp/build && \
    git clone --depth 1 https://github.com/jedisct1/pure-ftpd.git && \
    cd pure-ftpd && \
    ./autogen.sh && \
    ./configure --with-extauth --with-nonroot --with-virtualchroot --with-altlog --without-inetd --without-shadow --without-usernames --prefix=/opt/pureftpd && \
    make install-strip -j8 && \
    ls /opt/pureftpd && \
    cd /temp/build

RUN curl -sS -L -o paperless_auth --output-dir /temp/out/ --create-dirs "https://github.com/CrystalNET-org/pure-ftpd-paperless-dbauth/releases/download/${PAPERLESS_AUTH_VERSION}/verify_pw_${TARGETARCH}"

FROM harbor.crystalnet.org/dockerhub-proxy/alpine:3.20 AS image
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk --update-cache --no-cache upgrade && \
    apk add --update-cache --no-cache bash libsodium gcompat && \
    rm -rf /var/cache/apk/*

COPY --from=builder /opt /opt
COPY --from=builder /temp/out/paperless_auth /opt/pureftpd/sbin/
RUN chmod a+x /opt/pureftpd/sbin/paperless_auth
ADD rootfs /
RUN ls /opt/pureftpd/sbin

ENTRYPOINT [ "/entrypoint.sh" ]
