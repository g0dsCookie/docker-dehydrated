FROM alpine:3.7

RUN apk add --no-cache --virtual .dehydrated-deps \
        libressl \
        sed \
        grep \
        coreutils \
        diffutils \
        curl \
        nginx

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
 && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 3C2F2605E078A1E18F4793909C4DBE6CF438F333 \
 && gpg --batch --verify "${BDIR}/dehydrated.tar.gz.asc" "${BDIR}/dehydrated.tar.gz" \
 && apk del gnupg \
 && rm -r "${GNUPGHOME}" \
 && cd "${BDIR}" \
 && tar -xzf "dehydrated.tar.gz" && cd "dehydrated-${MAJOR}.${MINOR}.${PATCH}" \
 && mv "dehydrated" "/usr/bin/dehydrated" \
 && cd \
 && rm -r "${BDIR}"

ENTRYPOINT [ "/docker-entrypoint.sh" ]