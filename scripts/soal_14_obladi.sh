#!/bin/bash
# SOAL 14: Pencatatan IP Asli Pengunjung (Real Client IP) dengan mod_remoteip pada Apache
a2enmod remoteip 2>/dev/null || true

mkdir -p /etc/apache2/conf-available
cat << 'EOF' > /etc/apache2/conf-available/remoteip.conf
RemoteIPHeader X-Real-IP
RemoteIPInternalProxy 192.220.4.0/24
RemoteIPInternalProxy 192.220.4.2
EOF

a2enconf remoteip
sed -i 's/%h/%a/g' /etc/apache2/apache2.conf
apache2ctl configtest
service apache2 restart
echo "[OK] Soal 14 configured on Vault."

