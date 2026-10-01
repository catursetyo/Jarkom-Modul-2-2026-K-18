#!/bin/bash
# SOAL 15: Dedicated Path /orion menyajikan file statis tanpa PHP
mkdir -p /var/www/orion
cat << 'HTML' > /var/www/orion/index.html
<!DOCTYPE html><html><head><title>Orion</title></head><body><h1>Welcome to /ori>
HTML

nginx -t
service nginx restart
echo "[OK] Soal 15 configured on Abbey."
