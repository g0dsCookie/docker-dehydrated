FROM alpine:3.10

ARG MAJOR
ARG MINOR
ARG PATCH

LABEL maintainer="g0dsCookie <g0dscookie@cookieprojects.de>" \
      version="${MAJOR}.${MINOR}.${PATCH}" \
      description="letsencrypt/acme client implemented as a shell-script"

RUN set -eu \
 && cecho() { echo "\033[1;32m$1\033[0m"; } \
 && cecho "##### INSTALLING DEHYDRATED DEPENDENCIES" \
 && apk add --no-cache --virtual .dehydrated-deps \
       openssl sed grep coreutils diffutils curl nginx bash \
 && apk add --no-cache --virtual .dehydrated-bdeps \
       gnupg \
 && BDIR="$(mktemp -d)" && cd "${BDIR}" \
 && curl -sSL -o "dehydrated.tar.gz" "https://github.com/lukas2511/dehydrated/releases/download/v${MAJOR}.${MINOR}.${PATCH}/dehydrated-${MAJOR}.${MINOR}.${PATCH}.tar.gz" \
 && curl -sSL -o "dehydrated.tar.gz.asc" "https://github.com/lukas2511/dehydrated/releases/download/v${MAJOR}.${MINOR}.${PATCH}/dehydrated-${MAJOR}.${MINOR}.${PATCH}.tar.gz.asc" \
 && export GNUPGHOME="$(mktemp -d)" \
 && gpg --recv-keys 3C2F2605E078A1E18F4793909C4DBE6CF438F333 \
 && gpg --batch --verify "dehydrated.tar.gz.asc" "dehydrated.tar.gz" \
 && tar -xzf "dehydrated.tar.gz" \
 && cd "dehydrated-${MAJOR}.${MINOR}.${PATCH}" \
 && install -o root -g root -m 0555 "dehydrated" "/usr/bin/dehydrated" \
 && cecho "##### CLEANING BUILD ENVIRONMENT #####" \
 && cd && rm -r "${BDIR}" && apk del .dehydrated-bdeps \
 && mkdir -p /certificates /data /var/www/dehydrated

COPY content/ /

EXPOSE 80

VOLUME [ "/certificates", "/data", "/init.d", "/hooks.d", "/domains.txt" ]

ENV CA=https://acme-v02.api.letsencrypt.org/directory \
    KEYSIZE=4096 \
    RENEW_DAYS=30 \
    PRIVATE_KEY_REGEN=yes \
    KEY_ALGO=rsa \
    CONTACT_EMAIL=webmaster@example.org \
    SLEEP=86400 \
    CHALLENGE=http-01

ENTRYPOINT [ "/docker-entrypoint.sh" ]
