#!/bin/sh
# SOAL 18: Simulasi perubahan A record abbey.k18.com dengan TTL 15 detik

ACTION="${1:-demo}"

if [ "$ACTION" = "demo" ]; then
    echo "=================================================================="
    echo " FASE 1: Sebelum Perubahan (IP Lama)"
    echo "=================================================================="
    dig @127.0.0.1 abbey.k18.com +noall +answer

    echo "
>>> Mengubah A record abbey.k18.com ke IP fiktif 10.99.99.99 dengan TTL 15s..."
    sed -i 's/abbey\s\+IN\s\+A\s\+192.220.3.2/abbey 15 IN A 10.99.99.99/' /etc/bind/db.k18.com
    OLD_SERIAL=$(grep -oE '[0-9]{10}' /etc/bind/db.k18.com | head -1)
    NEW_SERIAL=$((OLD_SERIAL + 1))
    sed -i "s/$OLD_SERIAL/$NEW_SERIAL/" /etc/bind/db.k18.com
    named-checkzone k18.com /etc/bind/db.k18.com
    kill $(pidof named) 2>/dev/null; sleep 1; mkdir -p /run/named; chown bind:bind /run/named; named -u bind; sleep 2

    echo "
=================================================================="
    echo " FASE 2: Sesaat setelah perubahan (Jeda TTL 15 detik)"
    echo "=================================================================="
    dig @127.0.0.1 abbey.k18.com +noall +answer

    echo "
>>> Menunggu 16 detik hingga batas waktu TTL 15s habis..."
    sleep 16

    echo "
=================================================================="
    echo " FASE 3: Setelah batas TTL 15 detik habis"
    echo "=================================================================="
    dig @127.0.0.1 abbey.k18.com +noall +answer

    echo "
>>> Mengembalikan koordinat normal per instruksi Soal 20..."
    sed -i 's/abbey\s\+15\s\+IN\s\+A\s\+10.99.99.99/abbey IN A 192.220.3.2/' /etc/bind/db.k18.com
    OLD_SERIAL=$(grep -oE '[0-9]{10}' /etc/bind/db.k18.com | head -1)
    NEW_SERIAL=$((OLD_SERIAL + 1))
    sed -i "s/$OLD_SERIAL/$NEW_SERIAL/" /etc/bind/db.k18.com
    named-checkzone k18.com /etc/bind/db.k18.com
    kill $(pidof named) 2>/dev/null; sleep 1; mkdir -p /run/named; chown bind:bind /run/named; named -u bind; sleep 2

    echo "
[RESTORED] Koordinat Abbey kembali normal:"
    dig @127.0.0.1 abbey.k18.com +noall +answer
