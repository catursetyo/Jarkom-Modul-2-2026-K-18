#!/bin/sh
echo 'nameserver 192.168.122.1' > /etc/resolv.conf
cat /etc/resolv.conf
ping -c 2 google.com
