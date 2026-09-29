# rootkit
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 192.220.5.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 192.220.3.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 192.220.4.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 192.220.1.1
    netmask 255.255.255.0

auto eth5
iface eth5 inet static
    address 192.220.2.1
    netmask 255.255.255.0
EOF

# alpha
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.220.1.2
    netmask 255.255.255.0
    gateway 192.220.1.1
EOF

# beta
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.220.1.3
    netmask 255.255.255.0
    gateway 192.220.1.1
EOF

# gamma
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.220.1.4
    netmask 255.255.255.0
    gateway 192.220.1.1
EOF

# delta
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.220.2.2
    netmask 255.255.255.0
    gateway 192.220.2.1
EOF

# epsilon
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.220.2.3
    netmask 255.255.255.0
    gateway 192.220.2.1
EOF

# abbey
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.220.3.2
    netmask 255.255.255.0
    gateway 192.220.3.1
EOF

# penny
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.220.4.2
    netmask 255.255.255.0
    gateway 192.220.4.1
EOF

# prab
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.220.5.2
    netmask 255.255.255.0
    gateway 192.220.5.1
EOF

# tedd
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.220.5.3
    netmask 255.255.255.0
    gateway 192.220.5.1
EOF

# obladi
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.220.5.4
    netmask 255.255.255.0
    gateway 192.220.5.1
EOF

# desmond
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.220.5.5
    netmask 255.255.255.0
    gateway 192.220.5.1
EOF

# oblada
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.220.5.6
    netmask 255.255.255.0
    gateway 192.220.5.1
EOF

# molly
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.220.5.7
    netmask 255.255.255.0
    gateway 192.220.5.1
EOF
