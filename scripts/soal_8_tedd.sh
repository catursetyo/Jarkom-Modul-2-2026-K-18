#!/bin/sh

# tedd
cat <<'EOF' > /etc/bind/named.conf.local
zone "k18.com" {
        type slave;
        masters { 192.220.5.2; };
        file "/var/lib/bind/db.k18.com";
};

zone "3.220.192.in-addr.arpa" {
        type slave;
        masters { 192.220.5.2; };
        file "/var/lib/bind/db.192.220.3";
};

zone "4.220.192.in-addr.arpa" {
        type slave;
        masters { 192.220.5.2; };
        file "/var/lib/bind/db.192.220.4";
};

zone "5.220.192.in-addr.arpa" {
        type slave;
        masters { 192.220.5.2; };
        file "/var/lib/bind/db.192.220.5";
};
EOF

named-checkconf

kill $(pidof named) 2>/dev/null
sleep 1
mkdir -p /run/named
chown bind:bind /run/named
named -u bind
sleep 4

# --- verifikasi slave: 3 file zona reverse harus tertarik ---
ls -la /var/lib/bind/

# --- reverse dari tedd + bukti authoritative ---
echo "--- abbey ---"
dig -x 192.220.3.2 @192.220.5.3 +short
echo "--- penny ---"
dig -x 192.220.4.2 @192.220.5.3 +short
echo "--- vault ---"
dig -x 192.220.5.4 @192.220.5.3 +short
dig -x 192.220.5.5 @192.220.5.3 +short
echo "--- core ---"
dig -x 192.220.5.6 @192.220.5.3 +short
dig -x 192.220.5.7 @192.220.5.3 +short
echo "--- flags dari tedd (harus 'aa') ---"
dig -x 192.220.5.7 @192.220.5.3 | grep flags
