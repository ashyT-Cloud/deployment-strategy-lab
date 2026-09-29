#!/bin/bash

set -e

echo "Starting rolling deployment..."

echo "Current stable version:"
curl -s http://localhost:8080/version
echo

echo "Starting new version..."

docker compose up -d app-green

echo "New version is running:"
docker exec deployment-app-green \
  python -c "import urllib.request; print(urllib.request.urlopen('http://localhost:5000/version').read().decode())"

echo "Switching traffic to new version..."

sed -i 's/server app-blue:5000;/server app-green:5000;/' nginx/nginx.conf

docker compose up -d --force-recreate nginx

echo "Deployment complete."

curl -s http://localhost:8080/version

echo
