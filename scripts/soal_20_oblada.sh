#!/bin/sh
# SOAL 20: Autostart & normal state persistence on Core Node
service $(service --status-all 2>&1 | grep -o 'php[0-9.]*-fpm' | head -n 1) sta>
service nginx start 2>/dev/null || true
echo "[OK] Core Nginx & PHP-FPM Active."
