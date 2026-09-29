#!/bin/bash

set -e

echo "Rolling back production traffic to stable v1..."

cat > nginx/nginx.conf <<'NGINX'
events {}

http {

    upstream application {
        server app-blue:5000;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://application;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
NGINX

docker compose up -d --force-recreate nginx

echo "Rollback complete."

curl -s http://localhost:8080/version

echo
