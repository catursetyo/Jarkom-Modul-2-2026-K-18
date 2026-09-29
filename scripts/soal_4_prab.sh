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
        type master;
        file "/etc/bind/db.k18.com";
        allow-transfer { 192.220.5.3; };
        notify yes;
        also-notify { 192.220.5.3; };
};
EOF

cat <<'EOF' > /etc/bind/db.k18.com
$TTL    604800
@       IN      SOA     prab.k18.com. root.k18.com. (
                        2026092901      ; Serial
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
@       IN      NS      prab.k18.com.
@       IN      NS      tedd.k18.com.
prab    IN      A       192.220.5.2
tedd    IN      A       192.220.5.3
@       IN      A       192.220.4.2
EOF

chmod 644 /etc/bind/db.k18.com

named-checkconf
named-checkzone k18.com /etc/bind/db.k18.com

# trixie tidak punya init.d bind9 -> start daemon manual (idempotent)
if ! pgrep -x named > /dev/null 2>&1; then
    mkdir -p /run/named
    chown bind:bind /run/named
    named -u bind
fi
sleep 2

# verif
dig @192.220.5.2 k18.com SOA +short
dig @192.220.5.2 prab.k18.com +short
dig @192.220.5.2 k18.com A +short
