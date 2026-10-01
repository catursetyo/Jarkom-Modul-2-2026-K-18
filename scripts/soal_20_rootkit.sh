#!/bin/sh
# SOAL 20: Autostart & normal state persistence on Rootkit
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || iptables -t>
echo "[OK] Rootkit IP Forwarding & NAT Active."
