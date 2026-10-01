#!/bin/sh
# SOAL 20: Autostart & normal state persistence on Client
cat <<'EOF' > /etc/resolv.conf
nameserver 192.220.5.2
nameserver 192.220.5.3
nameserver 192.168.122.1
EOF
echo "[OK] Client Resolver Configured."