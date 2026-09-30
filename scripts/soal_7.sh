#!/bin/sh

# prab
cat <<'EOF' > /etc/bind/db.k18.com
$TTL    604800
@       IN      SOA     prab.k18.com. root.k18.com. (
                        2026092904      ; Serial (naik dari 2026092903)
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
rootkit IN      A       192.220.5.1
alpha   IN      A       192.220.1.2
beta    IN      A       192.220.1.3
gamma   IN      A       192.220.1.4
delta   IN      A       192.220.2.2
epsilon IN      A       192.220.2.3
abbey   IN      A       192.220.3.2
penny   IN      A       192.220.4.2
obladi  IN      A       192.220.5.4
desmond IN      A       192.220.5.5
oblada  IN      A       192.220.5.6
molly   IN      A       192.220.5.7
vault   IN      A       192.220.5.4
vault   IN      A       192.220.5.5
core    IN      A       192.220.5.6
core    IN      A       192.220.5.7
www     IN      CNAME   penny.k18.com.
static  IN      CNAME   abbey.k18.com.
EOF

chmod 644 /etc/bind/db.k18.com
named-checkzone k18.com /etc/bind/db.k18.com || exit 1

kill $(pidof named) 2>/dev/null
sleep 1
mkdir -p /run/named
chown bind:bind /run/named
named -u bind
sleep 4

# verif dari master
echo "--- vault (harus 2 IP: obladi + desmond) ---"
dig @192.220.5.2 vault.k18.com A +short
echo "--- core (harus 2 IP: oblada + molly) ---"
dig @192.220.5.2 core.k18.com A +short
echo "--- www -> penny ---"
dig @192.220.5.2 www.k18.com +short
echo "--- static -> abbey ---"
dig @192.220.5.2 static.k18.com +short
echo "--- serial sinkron ---"
dig @192.220.5.2 k18.com SOA +short | grep -o '2026092904'
dig @192.220.5.3 k18.com SOA +short | grep -o '2026092904'
