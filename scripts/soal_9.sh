#!/bin/sh

# obladi & desmond
apt-get update
apt-get install -y apache2

mkdir -p /var/www/html/arsip
echo "dokumen rahasia di $(hostname)" > /var/www/html/arsip/$(hostname).txt
echo "arsip lama tahun 2025" > /var/www/html/arsip/lama.txt

cat <<'EOF' > /etc/apache2/conf-available/arsip.conf
<Directory /var/www/html/arsip>
        Options +Indexes
        Require all granted
</Directory>
EOF
a2enconf arsip

if pgrep apache2 > /dev/null 2>&1; then
    apache2ctl graceful
else
    apache2ctl start
fi

pgrep apache2 > /dev/null && echo "[OK] apache running"
curl -s http://localhost/arsip/ | head -5
