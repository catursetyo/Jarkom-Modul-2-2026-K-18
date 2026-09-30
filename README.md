# Jarkom-Modul-2-2026-K-18

| Host | IP | Gateway |
|---|---|---|
| alpha | `192.220.1.2/24` | `192.220.1.1` |
| beta | `192.220.1.3/24` | `192.220.1.1` |
| gamma | `192.220.1.4/24` | `192.220.1.1` |
| delta | `192.220.2.2/24` | `192.220.2.1` |
| epsilon | `192.220.2.3/24` | `192.220.2.1` |
| abbey | `192.220.3.2/24` | `192.220.3.1` |
| penny | `192.220.4.2/24` | `192.220.4.1` |
| prab | `192.220.5.2/24` | `192.220.5.1` |
| tedd | `192.220.5.3/24` | `192.220.5.1` |
| obladi | `192.220.5.4/24` | `192.220.5.1` |
| desmond | `192.220.5.5/24` | `192.220.5.1` |
| oblada | `192.220.5.6/24` | `192.220.5.1` |
| molly | `192.220.5.7/24` | `192.220.5.1` |

---

## Laporan Pengerjaan Soal 1–10 (sementara)

### Soal 1 — Pengalamatan IP & default gateway (`scripts/soal_1.sh`)

- **rootkit** sebagai router sentral: `eth0` (WAN, DHCP dari node NAT) + 5 interface LAN — `eth1` 192.220.5.1 (Switch1: prab/tedd/vault/core), `eth2` 192.220.3.1 (abbey), `eth3` 192.220.4.1 (penny), `eth4` 192.220.1.1 (alpha/beta/gamma), `eth5` 192.220.2.1 (delta/epsilon).
- 13 host non-router memakai konfigurasi statis di `/etc/network/interfaces` dengan gateway mengarah ke IP rootkit di segmennya masing-masing (tabel di atas).
- **Verifikasi**: `ip a` + `ip route` (ada `default via ...`), ping gateway dari tiap host, ping balik dari rootkit.

### Soal 2 — NAT & WAN rootkit (`scripts/soal_2.sh`, di rootkit)

- WAN `eth0` diaktifkan statis `192.168.122.221/24`, default route via `192.168.122.1`, resolver sementara `192.168.122.1`.
- IP forwarding: `net.ipv4.ip_forward=1` (dipersistenkan ke `/etc/sysctl.conf`).
- NAT: `iptables -t nat -A POSTROUTING -s 192.220.0.0/16 -o eth0 -j MASQUERADE` (dengan `-C` check agar idempotent).
- **Verifikasi**: `ping 8.8.8.8` dari host internal (alpha, delta, molly, dll.) sukses.

### Soal 3 — Routing internal & resolver awal (`scripts/soal_3.sh`)

- Seluruh host non-router menambahkan `nameserver 192.168.122.1` di `/etc/resolv.conf` agar bisa mengunduh paket sejak awal.
- **Verifikasi**: ping lintas segmen (alpha ↔ molly, abbey → delta, dst.) membuktikan routing internal via rootkit berfungsi; `ping google.com` sukses.

### Soal 4 — DNS master prab + slave tedd (`scripts/soal_4_prab.sh`, `soal_4_tedd.sh`, `soal_4_resolver.sh`)

- **prab (ns1)**: bind9, zona `k18.com` type master (`/etc/bind/db.k18.com`) — SOA `prab.k18.com`, NS `prab` + `tedd`, A record prab/tedd, A apex `k18.com` → penny (192.220.4.2). `notify yes` + `allow-transfer` ke tedd. `forwarders { 192.168.122.1; }`.
- **tedd (ns2)**: zona `k18.com` type slave, `masters { 192.220.5.2; }`, file di `/var/lib/bind/db.k18.com`.
- Resolver semua Entitas non-router diurutkan: **IP prab → IP tedd → 192.168.122.1**.
- Catatan teknis: Debian trixie tidak menyertakan init script bind9, sehingga named dinyalakan manual (`named -u bind`, lihat `scripts/named_start.sh`).
- **Verifikasi**: `named-checkzone` OK, transfer terjadi (`/var/lib/bind/` terisi), `dig @tedd k18.com SOA` serial `2026092901` sama dengan prab, flag jawaban `aa`.

### Soal 5 — Hostname & domain per node (`scripts/soal_5_hostname.sh`, `soal_5_zone.sh`)

- Semua Entitas dinamai sesuai glosarium (runtime + `/etc/hostname`) dan dikenali system-wide lewat entry `/etc/hosts` `<IP> <nama>.k18.com <nama>`; verifikasi `hostname -f` mengembalikan FQDN.
- Zona diperbarui dengan A record untuk seluruh node (rootkit, alpha, beta, gamma, delta, epsilon, abbey, penny, obladi, desmond, oblada, molly) — prab & tedd dikecualikan karena NS+A-nya sudah ada sejak soal 4. Serial naik ke `2026092902`.
- **Verifikasi**: `dig alpha.k18.com +short` dari master & slave menghasilkan IP yang sama; ping hostname antar node.

### Soal 6 — Verifikasi zone transfer (`scripts/soal_6.sh`)

- Serial SOA dinaikkan (`2026092903`) di prab → notify memicu tedd menarik zona terbaru.
- **Verifikasi**: serial prab = serial tedd (`2026092903`), `dig @tedd ... | grep flags` memuat `aa` (tedd menjawab authoritative dari salinannya).

### Soal 7 — vault/core + CNAME (`scripts/soal_7.sh`)

- A record `vault.k18.com` → obladi (192.220.5.4) **dan** desmond (192.220.5.5); `core.k18.com` → oblada (192.220.5.6) **dan** molly (192.220.5.7).
- CNAME `www.k18.com` → `penny.k18.com`; `static.k18.com` → `abbey.k18.com`. Serial naik ke `2026092904`.
- **Verifikasi**: `dig` dari prab & tedd + uji dari dua klien berbeda (alpha & molly) — hasil resolve konsisten.

### Soal 8 — Reverse zone (PTR) (`scripts/soal_8_prab.sh`, `soal_8_tedd.sh`)

- prab mendeklarasikan 3 zona reverse sebagai master: `3.220.192.in-addr.arpa` (abbey), `4.220.192.in-addr.arpa` (penny), `5.220.192.in-addr.arpa` (vault: obladi/desmond + core: oblada/molly), masing-masing `notify` + `allow-transfer` ke tedd, berisi PTR `2→abbey`, `2→penny`, `4→obladi`, `5→desmond`, `6→oblada`, `7→molly`.
- tedd menarik ketiganya sebagai slave (config `type slave` di `named.conf.local` milik tedd — zone transfer hanya menyalin data zona, bukan config server).
- **Verifikasi**: `dig -x 192.220.3.2 @192.220.5.3 +short` → `abbey.k18.com.` dst. untuk keenam IP, flag `aa` dari tedd; `nslookup <IP>` dari klien.

### Soal 9 — Web statis + autoindex area vault (`scripts/soal_9.sh`, di obladi & desmond)

- Install `apache2`; direktori `/var/www/html/arsip/` diisi file contoh (diberi nama hostname untuk demo).
- Autoindex diaktifkan via `/etc/apache2/conf-available/arsip.conf`: `<Directory /var/www/html/arsip> Options +Indexes Require all granted </Directory>` + `a2enconf arsip`; apache dinyalakan `apache2ctl start` (idempotent).
- **Verifikasi**: `wget -O- http://obladi.k18.com/arsip/` dan `http://desmond.k18.com/arsip/` (via **hostname**, bukan IP) mengembalikan halaman `Index of /arsip` berisi daftar file.

### Soal 10 — Web dinamis nginx + PHP-FPM area core (`scripts/soal_10.sh`, di oblada & molly)

- Install `nginx php-fpm` (PHP 8.4, sesuai saran modul); aplikasi beranda (`/var/www/html/index.html`) + halaman profil (`profil.php` yang mencetak `gethostname()` + `phpversion()`).
- URL bersih: `location = /profil { rewrite ^ /profil.php last; }` dan `location ~ \.php$ { fastcgi_pass unix:/run/php/php8.4-fpm.sock; }`; nginx & php-fpm dinyalakan manual (idempotent).
- **Verifikasi**: dari host lain via hostname — `wget -O- http://oblada.k18.com/profil` → "Profil oblada ... PHP 8.4.26 via PHP-FPM", `http://molly.k18.com/profil` → "Profil molly ..." (konten berbeda per node membuktikan eksekusi PHP dinamis).

---

## Resolver (soal 4c — jalankan di semua host non-router)

Urutan resolver: **prab → tedd → 192.168.122.1**. Satu tempel per node:

```bash
echo "nameserver 192.220.5.2
nameserver 192.220.5.3
nameserver 192.168.122.1" > /etc/resolv.conf
cat /etc/resolv.conf
ping -c 2 k18.com
```

Catatan: `/etc/resolv.conf` di-reset oleh docker setiap node restart, jadi command ini harus dijalankan ulang setelahnya (lihat `scripts/soal_4_resolver.sh`).

## Recovery prab & tedd

### Kasus 1 — stop/start biasa (paket & config masih ada)

Debian trixie tidak menyertakan init script `bind9`, jadi named hanya perlu dinyalakan manual:

```bash
mkdir -p /run/named && chown bind:bind /run/named && named -u bind
```

Versi idempotent (aman dijalankan berulang): `scripts/named_start.sh`.

### Kasus 2 — node ter-wipe / filesystem ter-reset (paket & config hilang)

Ciri-cirinya: `id bind` → no such user, `ls /etc/bind` → No such file or directory.

```bash
# 1) resolver sementara untuk apt (named belum jalan)
echo 'nameserver 192.168.122.1' > /etc/resolv.conf

# 2) install ulang bind9
apt-get update && apt-get install -y bind9 bind9-utils bind9-dnsutils

# 3) re-apply config dari script
#    di prab: soal_4_prab.sh -> soal_5_zone.sh -> soal_7.sh -> soal_8_prab.sh
#    di tedd: soal_4_tedd.sh -> soal_8_tedd.sh

# 4) verifikasi
dig @192.220.5.2 k18.com SOA +short     # 2026092904
dig -x 192.220.3.2 @192.220.5.2 +short  # abbey.k18.com.
```

## Resolver di prab & tedd

prab dan tedd termasuk Entitas non-router, jadi resolver-nya sama dengan host lain (jalankan **setelah** named hidup):

```bash
echo "nameserver 192.220.5.2
nameserver 192.220.5.3
nameserver 192.168.122.1" > /etc/resolv.conf
cat /etc/resolv.conf
ping -c 2 k18.com
```
