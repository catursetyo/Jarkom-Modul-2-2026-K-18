#!/bin/sh

# 
apt-get update
apt-get install -y nginx php-fpm curl

cat <<'EOF' > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head><title>Beranda</title></head>
<body><h1>Beranda The Mesh</h1><p>Layanan web dinamis area core.</p></body>
</html>
EOF

cat <<'EOF' > /var/www/html/profil.php
<?php
echo "<h1>Profil " . gethostname() . "</h1>";
echo "<p>Halaman profil diakses via URL bersih: /profil</p>";
echo "<p>PHP " . phpversion() . " via PHP-FPM</p>";
EOF

cat <<'EOF' > /etc/nginx/sites-available/default
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;
        index index.html index.php;

        location / {
                try_files $uri $uri/ =404;
        }

        location = /profil {
                rewrite ^ /profil.php last;
        }

        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        }
}
EOF

nginx -t || exit 1

mkdir -p /run/php
pgrep -x nginx > /dev/null 2>&1 || nginx
pgrep -f php-fpm > /dev/null 2>&1 || php-fpm8.4

sleep 1
pgrep -x nginx > /dev/null && echo "[OK] nginx running"
pgrep -f php-fpm > /dev/null && echo "[OK] php-fpm running"

# verif
curl -s http://localhost/
echo
curl -s http://localhost/profil
