FROM alpine:3.7

RUN apk add --no-cache --virtual .dehydrated-deps \
        libressl \
        sed \
        grep \
        coreutils \
        diffutils \
        curl \
        nginx \
        bash

COPY content/ /

ARG MAJOR
ARG MINOR
ARG PATCH

RUN set -eu \
 && BDIR="$(mktemp -d)" \
 && wget -qO "${BDIR}/dehydrated.tar.gz" \
        "https://github.com/lukas2511/dehydrated/releases/download/v${MAJOR}.${MINOR}.${PATCH}/dehydrated-${MAJOR}.${MINOR}.${PATCH}.tar.gz" \
 && wget -qO "${BDIR}/dehydrated.tar.gz.asc" \
        "https://github.com/lukas2511/dehydrated/releases/download/v${MAJOR}.${MINOR}.${PATCH}/dehydrated-${MAJOR}.${MINOR}.${PATCH}.tar.gz.asc" \
 && apk add --no-cache gnupg \
 && export GNUPGHOME="$(mktemp -d)" \
 && gpg --recv-keys 3C2F2605E078A1E18F4793909C4DBE6CF438F333 \
 && gpg --batch --verify "${BDIR}/dehydrated.tar.gz.asc" "${BDIR}/dehydrated.tar.gz" \
 && apk del gnupg \
 && rm -rf "${GNUPGHOME}" \
 && cd "${BDIR}" \
 && tar -xzf "dehydrated.tar.gz" && cd "dehydrated-${MAJOR}.${MINOR}.${PATCH}" \
 && mv "dehydrated" "/usr/bin/dehydrated" \
 && cd \
 && rm -r "${BDIR}" \
 && mkdir -p /certificates /var/www/dehydrated

EXPOSE 80

VOLUME [ "/certificates", "/domains.txt", "/data" ]

ENV     CA="https://acme-v01.api.letsencrypt.org/directory" \
        KEYSIZE=4096 \
        RENEW_DAYS=30 \
        PRIVATE_KEY_REGEN="yes" \
        KEY_ALGO="rsa" \
        CONTACT_EMAIL="webmaster@example.org" \
        SLEEP=86400

ENTRYPOINT [ "/docker-entrypoint.sh" ]