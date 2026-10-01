#!/bin/bash
# SOAL 14: Pencatatan IP Asli Pengunjung (Real Client IP) dengan real_ip pada N>
mkdir -p /etc/nginx/conf.d
cat << 'EOF' > /etc/nginx/conf.d/realip.conf
set_real_ip_from 192.220.3.0/24;
set_real_ip_from 192.220.3.2;
real_ip_header X-Real-IP;
real_ip_recursive on;
EOF

nginx -t
service nginx restart
echo "[OK] Soal 14 configured on Core."
