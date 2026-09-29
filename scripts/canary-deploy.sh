#!/bin/bash

set -e

PERCENTAGE="${1:-10}"

case "$PERCENTAGE" in
    10|25|50)
        ;;
    100)
        ;;
    *)
        echo "Usage: $0 {10|25|50|100}"
        exit 1
        ;;
esac

echo "Deploying canary traffic: ${PERCENTAGE}%"

if [[ "$PERCENTAGE" == "100" ]]; then

cat > nginx/nginx.conf <<'NGINX'
events {}

http {
    upstream application {
        server app-green:5000;
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

else

if [[ "$PERCENTAGE" == "10" ]]; then
    STABLE=90
elif [[ "$PERCENTAGE" == "25" ]]; then
    STABLE=75
else
    STABLE=50
fi

cat > nginx/nginx.conf <<NGINX
events {}

http {

    upstream stable {
        server app-blue:5000;
    }

    upstream canary {
        server app-green:5000;
    }

    split_clients "\${http_x_canary_id}" \$deployment_backend {
        ${STABLE}% stable;
        * canary;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://\$deployment_backend;

            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
}
NGINX

fi

docker compose up -d --force-recreate nginx

echo
echo "Canary deployment configured: ${PERCENTAGE}%"
echo "Current response:"
curl -s http://localhost:8080/version
echo
