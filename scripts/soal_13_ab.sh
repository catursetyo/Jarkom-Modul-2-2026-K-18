  GNU nano 8.4                       soal_13.sh
#!/bin/bash
# SOAL 13: Canonical Redirect (302 Temporary) untuk IP & abbey.k18.com -> stati>
cat << 'EOF' > /etc/nginx/conf.d/abbey_redirect.conf
server {
    listen 80;
    server_name abbey.k18.com 192.220.3.2;
    return 302 http://static.k18.com$request_uri;
}
EOF

nginx -t
service nginx restart
echo "[OK] Soal 13 configured on Abbey."
