#!/bin/bash

set -e

TARGET="${1:-green}"

if [[ "$TARGET" != "blue" && "$TARGET" != "green" ]]; then
    echo "Usage: $0 [blue|green]"
    exit 1
fi

echo "Switching production traffic to $TARGET..."

if [[ "$TARGET" == "green" ]]; then
    sed -i 's/server app-blue:5000;/server app-green:5000;/' nginx/nginx.conf
else
    sed -i 's/server app-green:5000;/server app-blue:5000;/' nginx/nginx.conf
fi

docker compose up -d --force-recreate nginx

echo
echo "Traffic switched to $TARGET."
echo "Current application version:"

curl -s http://localhost:8080/version

echo
