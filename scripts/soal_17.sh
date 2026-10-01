#!/bin/sh
# SOAL 17: TXT record pada DNS untuk semua klien sayap kiri dan kanan

grep -q 'alpha.*TXT' /etc/bind/db.k18.com 2>/dev/null
if [ $? -ne 0 ]; then
    cat <<'EOF' >> /etc/bind/db.k18.com

; SOAL 17: TXT Records Klien
alpha   IN      TXT     "alpha"
beta    IN      TXT     "beta"
gamma   IN      TXT     "gamma"
delta   IN      TXT     "delta"
epsilon IN      TXT     "epsilon"
EOF
    # Increment serial
    OLD_SERIAL=$(grep -oE '[0-9]{10}' /etc/bind/db.k18.com | head -1)
    NEW_SERIAL=$((OLD_SERIAL + 1))
    sed -i "s/$OLD_SERIAL/$NEW_SERIAL/" /etc/bind/db.k18.com
fi

named-checkzone k18.com /etc/bind/db.k18.com || exit 1
kill $(pidof named) 2>/dev/null
sleep 1
mkdir -p /run/named
chown bind:bind /run/named
named -u bind
sleep 2

echo "--- Verifikasi TXT record dari PRAB ---"
for host in alpha beta gamma delta epsilon; do
    echo -n "$host.k18.com TXT: "
    dig @127.0.0.1 ${host}.k18.com TXT +short
done
