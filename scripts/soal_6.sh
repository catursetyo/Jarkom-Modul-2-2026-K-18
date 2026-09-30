#!/bin/sh

# prab
sed -i 's/2026092902/2026092903/' /etc/bind/db.k18.com
kill $(pidof named) 2>/dev/null
sleep 1
mkdir -p /run/named
chown bind:bind /run/named
named -u bind
sleep 4

echo "--- serial prab (ns1) ---"
dig @192.220.5.2 k18.com SOA +short
echo "--- serial tedd (ns2) ---"
dig @192.220.5.3 k18.com SOA +short

echo "--- flags jawaban dari tedd ---"
dig @192.220.5.3 alpha.k18.com A | grep flags
