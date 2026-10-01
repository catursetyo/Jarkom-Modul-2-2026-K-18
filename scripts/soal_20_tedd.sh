#!/bin/sh
# SOAL 20: Autostart & normal state persistence on Tedd
pgrep -x named > /dev/null 2>&1
if [ $? -ne 0 ]; then
    mkdir -p /run/named
    chown bind:bind /run/named
    named -u bind
    echo "named started."
else
    echo "named already running."
fi
echo "[OK] Tedd DNS Slave Active."
