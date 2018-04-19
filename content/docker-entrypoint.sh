#!/usr/bin/env bash

set -Eeuo pipefail

function die() {
    local _code=$1
    shift
    echo $@ >&2
    exit ${_code}
}

function cleanup() {
    nginx_stop
}
trap cleanup EXIT

function nginx_start() {
    [[ -e /nginx.pid ]] && return
    nginx -c /etc/nginx.conf
}

function nginx_stop() {
    [[ ! -e /nginx.pid ]] && return
    local pid=$(cat /nginx.pid)
    if ! kill ${pid}; then
        kill -9 ${pid} || die 5 "Could not kill nginx with pid ${pid}!"
    fi
    unset pid
}

for key in CA KEYSIZE RENEW_DAYS PRIVATE_KEY_REGEN KEY_ALGO CONTACT_EMAIL; do
    echo "Populating ${key} with value ${!key:-unset}..."
    sed -i "s/%{${key}}%/${!key//\//\\/}/g" /etc/dehydrated/config
done

if [[ "${1:-unset}" == "--clean" ]]; then
    rm -r "/data/*" "/data/.registered"
fi

if [[ ! -e "/data/.registered" ]]; then
    dehydrated --register --accept-terms
    touch /data/.registered
fi

while true; do
    nginx_start
    dehydrated --keep-going --cron
    nginx_stop
    dehydrated --cleanup
    sleep ${SLEEP}
done
