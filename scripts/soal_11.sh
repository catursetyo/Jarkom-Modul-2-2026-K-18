#!/bin/bash
# SOAL 11: Reverse Proxy & Load Balancer ke Area Vault (Obladi & Desmond)
apt-get update -qq
apt-get install -y -qq apache2
a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers rewrite 2>/dev/null || true

cat << 'EOF' > /etc/apache2/sites-available/penny.conf
<VirtualHost *:80>
    ServerName www.k18.com
    ServerAlias penny.k18.com

    <Proxy "balancer://vault_cluster">
        BalancerMember http://192.220.5.4:80
        BalancerMember http://192.220.5.5:80
        ProxySet lbmethod=byrequests
    </Proxy>

    ProxyPreserveHost On
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"
    RequestHeader set X-Forwarded-For "%{REMOTE_ADDR}s"

    ProxyPass /admin !
    ProxyPass /eternal !
    ProxyPass / balancer://vault_cluster/
    ProxyPassReverse / balancer://vault_cluster/
</VirtualHost>
EOF

a2dissite 000-default.conf 2>/dev/null || true
a2ensite penny.conf 2>/dev/null || true
apache2ctl configtest
service apache2 restart
echo "[OK] Soal 11 configured on Penny."
