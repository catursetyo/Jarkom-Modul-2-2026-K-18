#!/bin/sh

# ./soal_5.sh hostname
NAME="${1:-}"
if [ -z "$NAME" ]; then
    echo "usage: $0 <nama-node>"
    exit 1
fi

hostname "$NAME"
echo "$NAME" > /etc/hostname 2>/dev/null

IP=$(ip -4 -o addr show scope global | grep -v '192.168.122.' | head -1 | awk '{print $4}' | cut -d/ -f1)
grep -q "$NAME" /etc/hosts 2>/dev/null || echo "$IP $NAME.k18.com $NAME" >> /etc/hosts

echo "--- verifikasi ---"
hostname
hostname -f
