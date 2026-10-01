#!/bin/bash
# SOAL 12: Basic Authentication untuk path /admin di Penny
apt-get install -y -qq apache2-utils

mkdir -p /var/www/admin
echo "<h1>Welcome to Secret Syndicate Vault</h1>" > /var/www/admin/index.html

# Kredensial: user 'prabs', password 'pakar_pinter_jadi_goblok'
htpasswd -b -c /etc/apache2/.htpasswd prabs pakar_pinter_jadi_goblok

cat << 'EOF' > /etc/apache2/conf-available/admin_auth.conf
Alias /admin /var/www/admin

<Location "/admin">
    ProxyPass !
    AuthType Basic
    AuthName "Restricted Secret Vault"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
</Location>
EOF

a2enconf admin_auth
apache2ctl configtest
service apache2 restart
echo "[OK] Soal 12 configured on Penny."
