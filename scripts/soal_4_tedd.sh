#!/bin/sh
apt-get update
apt-get install -y bind9 bind9-utils bind9-dnsutils

cat <<'EOF' > /etc/bind/named.conf.options
options {
        directory "/var/cache/bind";

        forwarders {
                192.168.122.1;
        };

        dnssec-validation no;

        listen-on { any; };
        allow-query { any; };
        recursion yes;
};
EOF

cat <<'EOF' > /etc/bind/named.conf.local
zone "k18.com" {
        type slave;
        masters { 192.220.5.2; };
        file "/var/lib/bind/db.k18.com";
};
EOF

named-checkconf

# trixie tidak punya init.d bind9 -> start daemon manual (idempotent)
if ! pgrep -x named > /dev/null 2>&1; then
    mkdir -p /run/named
    chown bind:bind /run/named
    named -u bind
fi
sleep 3

# verif-
ls -la /var/lib/bind/
dig @192.220.5.3 k18.com SOA +short
dig @192.220.5.3 tedd.k18.com +short
dig @192.220.5.3 k18.com SOA | grep flags
