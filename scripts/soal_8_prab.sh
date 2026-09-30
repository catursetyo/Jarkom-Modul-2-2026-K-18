#!/bin/sh

# prab
# named.conf.local: zona k18.com (existing) + 3 reverse zone
cat <<'EOF' > /etc/bind/named.conf.local
zone "k18.com" {
        type master;
        file "/etc/bind/db.k18.com";
        allow-transfer { 192.220.5.3; };
        notify yes;
        also-notify { 192.220.5.3; };
};

zone "3.220.192.in-addr.arpa" {
        type master;
        file "/etc/bind/db.192.220.3";
        allow-transfer { 192.220.5.3; };
        notify yes;
        also-notify { 192.220.5.3; };
};

zone "4.220.192.in-addr.arpa" {
        type master;
        file "/etc/bind/db.192.220.4";
        allow-transfer { 192.220.5.3; };
        notify yes;
        also-notify { 192.220.5.3; };
};

zone "5.220.192.in-addr.arpa" {
        type master;
        file "/etc/bind/db.192.220.5";
        allow-transfer { 192.220.5.3; };
        notify yes;
        also-notify { 192.220.5.3; };
};
EOF

# --- PTR: abbey ---
cat <<'EOF' > /etc/bind/db.192.220.3
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
2       IN      PTR     abbey.k18.com.
EOF

# --- PTR: penny ---
cat <<'EOF' > /etc/bind/db.192.220.4
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
2       IN      PTR     penny.k18.com.
EOF

# --- PTR: vault (obladi, desmond) + core (oblada, molly) ---
cat <<'EOF' > /etc/bind/db.192.220.5
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
4       IN      PTR     obladi.k18.com.
5       IN      PTR     desmond.k18.com.
6       IN      PTR     oblada.k18.com.
7       IN      PTR     molly.k18.com.
EOF

chmod 644 /etc/bind/db.192.220.3 /etc/bind/db.192.220.4 /etc/bind/db.192.220.5

named-checkconf
named-checkzone 3.220.192.in-addr.arpa /etc/bind/db.192.220.3
named-checkzone 4.220.192.in-addr.arpa /etc/bind/db.192.220.4
named-checkzone 5.220.192.in-addr.arpa /etc/bind/db.192.220.5

kill $(pidof named) 2>/dev/null
sleep 1
mkdir -p /run/named
chown bind:bind /run/named
named -u bind
sleep 4

# verif reverse master
echo "--- abbey ---"
dig -x 192.220.3.2 @192.220.5.2 +short
echo "--- penny ---"
dig -x 192.220.4.2 @192.220.5.2 +short
echo "--- vault ---"
dig -x 192.220.5.4 @192.220.5.2 +short
dig -x 192.220.5.5 @192.220.5.2 +short
echo "--- core ---"
dig -x 192.220.5.6 @192.220.5.2 +short
dig -x 192.220.5.7 @192.220.5.2 +short
