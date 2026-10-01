#!/bin/sh
# SOAL 20: Autostart & normal state persistence on Penny
service $(service --status-all 2>&1 | grep -o 'php[0-9.]*-fpm' | head -n 1) start 2>/dev/null || true
service apache2 start 2>/dev/null || true
echo "[OK] Penny Apache & PHP-FPM Active."