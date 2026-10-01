  GNU nano 8.4                                                                         soal_13.sh
#!/bin/bash
# SOAL 13: Canonical Redirect (301 Permanent) untuk IP & penny.k18.com -> www.k18.com
a2enmod rewrite 2>/dev/null || true

cat << 'EOF' > /etc/apache2/sites-available/penny_redirect.conf
<VirtualHost *:80>
    ServerName penny.k18.com
    ServerAlias 192.220.4.2
    RewriteEngine On
    RewriteRule ^(.*)$ http://www.k18.com$1 [R=301,L]
</VirtualHost>
EOF

a2ensite penny_redirect.conf
apache2ctl configtest
service apache2 restart
echo "[OK] Soal 13 configured on Penny."
