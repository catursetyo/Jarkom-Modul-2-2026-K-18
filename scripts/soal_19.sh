#!/bin/sh
# SOAL 19: CNAME outbound.k18.com menuju http.badssl.com

grep -q 'outbound.*CNAME' /etc/bind/db.k18.com 2>/dev/null
if [ $? -ne 0 ]; then
    cat <<'EOF' >> /etc/bind/db.k18.com

; SOAL 19: External CNAME
outbound IN     CNAME   http.badssl.com.
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

echo "--- Verifikasi CNAME outbound.k18.com ---"
dig @127.0.0.1 outbound.k18.com +short
