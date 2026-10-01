  GNU nano 8.4                                                                         soal_15.sh
#!/bin/bash
# SOAL 15: Dedicated Path /eternal dengan rendering PHP (PHP-FPM)
apt-get update -qq
apt-get install -y -qq php-fpm
a2enmod proxy_fcgi 2>/dev/null || true

PHP_SOCK=$(find /run/php/ -name '*.sock' 2>/dev/null | head -n 1)
if [ -z "$PHP_SOCK" ]; then
    service $(service --status-all 2>&1 | grep -o 'php[0-9.]*-fpm' | head -n 1) start 2>/dev/null || true
    PHP_SOCK=$(find /run/php/ -name '*.sock' 2>/dev/null | head -n 1)
fi

mkdir -p /var/www/eternal
cat << 'PHP' > /var/www/eternal/index.php
<?php
echo "<h1>Welcome to /eternal on Penny</h1>\n";
echo "<p>PHP Rendering: ACTIVE</p>\n";
?>
PHP

cat << 'EOF' > /etc/apache2/conf-available/eternal_php.conf
Alias /eternal /var/www/eternal

<Directory "/var/www/eternal">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
    DirectoryIndex index.php index.html
    <FilesMatch "\.php$">
        SetHandler "proxy:unix:__PHP_SOCK__|fcgi://localhost/"
    </FilesMatch>
</Directory>

<Location "/eternal">
    ProxyPass !
</Location>
EOF

if [ -n "$PHP_SOCK" ]; then
    sed -i "s|__PHP_SOCK__|$PHP_SOCK|g" /etc/apache2/conf-available/eternal_php.conf
else
    sed -i "s|proxy:unix:__PHP_SOCK__|proxy:fcgi://127.0.0.1:9000|g" /etc/apache2/conf-available/eternal_php.conf
fi

a2enconf eternal_php
apache2ctl configtest
service apache2 restart
echo "[OK] Soal 15 configured on Penny."
