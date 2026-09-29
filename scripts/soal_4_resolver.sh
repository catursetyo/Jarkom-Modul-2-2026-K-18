#!/bin/sh

cat <<'EOF' > /etc/resolv.conf
nameserver 192.220.5.2
nameserver 192.220.5.3
nameserver 192.168.122.1
EOF

cat /etc/resolv.conf
ping -c 2 k18.com
