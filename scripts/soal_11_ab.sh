#!/bin/bash
# SOAL 11: Nginx Reverse Proxy & Load Balancer ke Area Core (Oblada & Molly)
apt-get update -qq
apt-get install -y -qq nginx

cat << 'EOF' > /etc/nginx/sites-available/abbey
upstream core_backend {
    server 192.220.5.6:80;
    server 192.220.5.7:80;
}

server {
    listen 80;
    server_name static.k18.com;

    location /orion/ {
        alias /var/www/orion/;
        index index.html;
    }

    location / {
        proxy_pass http://core_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

ln -sf /etc/nginx/sites-available/abbey /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
service nginx restart
echo "[OK] Soal 11 configured on Abbey."
