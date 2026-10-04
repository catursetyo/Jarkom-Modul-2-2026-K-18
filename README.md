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

### Soal 11 — Reverse Proxy & Load Balancer Abbey (`soal_11_ab.sh`, di abbey)

- **abbey**: Menggunakan Nginx sebagai reverse proxy yang mengarahkan lalu lintas domain `static.k18.com` ke *Area Core* (`core_backend` yang berisi IP Oblada `192.220.5.6:80` dan Molly `192.220.5.7:80`)[cite: 2, 21].
- Menambahkan header `Host`, `X-Real-IP`, dan `X-Forwarded-For` pada blok proxy agar IP asli client diteruskan[cite: 1, 2].
- **Verifikasi**: `nginx -t` OK, pengujian dari client `curl -H "Host: static.k18.com" http://192.220.3.2/profil` berhasil menampilkan respon dinamis dari node backend[cite: 2, 21].

---

### Soal 12 — Basic Authentication path `/admin` (`soal_12.sh`, di penny)

- **penny**: Membuat file kredensial `/etc/apache2/.htpasswd` menggunakan `htpasswd` berisi username `prabs` dan password `pakar_pinter_jadi_goblok`[cite: 1, 3].
- Menambahkan konfigurasi `<Location "/admin">` di Apache dengan `AuthType Basic` serta mematikan proxy pass khusus path tersebut (`ProxyPass !`)[cite: 3].
- **Verifikasi**: `curl -i http://www.k18.com/admin` mengembalikan status `401 Unauthorized`[cite: 3]. Pengaksesan dengan `curl -u prabs:pakar_pinter_jadi_goblok http://www.k18.com/admin` mengembalikan status `200 OK`[cite: 3].

---

### Soal 13 — Canonical Redirect (`soal_13.sh` di penny, `soal_13_ab.sh` di abbey)

- **penny**: Konfigurasi VirtualHost Apache untuk `penny.k18.com` dan IP `192.220.4.2` menggunakan `RewriteRule` dengan flag `[R=301,L]` yang memaksa redirect permanen ke `http://www.k18.com`[cite: 1, 4, 21].
- **abbey**: Konfigurasi server block Nginx untuk `abbey.k18.com` dan IP `192.220.3.2` yang mengembalikan `return 302 http://static.k18.com$request_uri;` (redirect sementara)[cite: 1, 5, 21].
- **Verifikasi**: Uji `curl -I http://192.220.4.2` mengembalikan `HTTP/1.1 301 Moved Permanently`[cite: 4], sedangkan `curl -I http://192.220.3.2` mengembalikan `HTTP/1.1 302 Moved Temporarily`[cite: 5].

---

### Soal 14 — Pencatatan Real Client IP di Log Backend (`soal_14_obladi.sh` di vault, `soal_14_oblada.sh` di core)

- **vault (obladi & desmond)**: Mengaktifkan modul `mod_remoteip` Apache, menentukan header `RemoteIPHeader X-Real-IP`, mendaftarkan IP proxy `192.220.4.0/24` sebagai trusted proxy, serta mengubah format LogFormat dari `%h` ke `%a`[cite: 7, 21].
- **core (oblada & molly)**: Menambahkan modul `set_real_ip_from` Nginx yang menunjuk ke IP/subnet proxy Abbey (`192.220.3.0/24`) dan menentukan `real_ip_header X-Real-IP;`[cite: 6, 21].
- **Verifikasi**: Melakukan request dari host client `alpha` (`192.220.1.2`) melalui proxy, lalu memeriksa `/var/log/apache2/access.log` di vault dan `/var/log/nginx/access.log` di core[cite: 6, 7, 21]. Log mencatat `192.220.1.2`, bukan IP proxy[cite: 6, 7, 21].

---

### Soal 15 — Dedicated Path `/eternal` & `/orion` (`soal_15.sh` di penny, `soal_15_ab.sh` di abbey)

- **penny**: Membuat path lokal `/var/www/eternal` yang mengeksekusi script PHP melalui PHP-FPM socket/FastCGI proxy (`proxy:unix:...|fcgi://localhost/`), serta menambahkan `ProxyPass !` agar tidak di-forward ke backend[cite: 1, 8].
- **abbey**: Membuat path lokal `/var/www/orion` yang menyajikan file statis `index.html` murni tanpa eksekusi PHP melalui directive `alias /var/www/orion/;` di Nginx[cite: 1, 2, 9].
- **Verifikasi**: Uji `curl http://www.k18.com/eternal/` berhasil merender "PHP Rendering: ACTIVE"[cite: 8]. Uji `curl http://static.k18.com/orion/` menampilkan halaman statis HTML[cite: 9].

---

### Soal 16 — Stress Test Benchmark dengan ApacheBench (`soal_16.sh`, dari client Alpha)

- Menginstal `apache2-utils` pada client `alpha`[cite: 10].
- Menjalankan perintah pengujian:
  - `ab -n 250 -c 10 http://www.k18.com/` (menguji Penny → Vault)[cite: 10].
  - `ab -n 250 -c 10 http://static.k18.com/` (menguji Abbey → Core)[cite: 10].
- **Verifikasi**: Rangkuman log tersimpan di `/tmp/ab_penny.log` dan `/tmp/ab_abbey.log`, menunjukkan total 250 requests selesai diselesaikan (0 failed requests) dengan metrik *Requests per second* yang tercatat[cite: 10].

---

### Soal 17 — DNS TXT Record Klien Sayap Kiri & Kanan (`soal_17.sh`, di prab)

- Mengedit file zona `/etc/bind/db.k18.com` di `prab` untuk menambahkan TXT record pada kelima node client: `alpha`, `beta`, `gamma`, `delta`, dan `epsilon` yang mengembalikan nama host masing-masing (misal: `alpha IN TXT "alpha"`)[cite: 1, 17, 21].
- Menaikkan serial SOA di prab untuk memicu sinkronisasi ke slave `tedd`[cite: 1, 17].
- **Verifikasi**: Perintah `dig @127.0.0.1 alpha.k18.com TXT +short` mengembalikan respon `"alpha"`[cite: 17].

---

### Soal 18 — Simulasi Perubahan A Record & TTL 15s (`soal_18.sh`, di prab)

- Mengubah A record `abbey.k18.com` pada zone file di prab menjadi IP fiktif `10.99.99.99` dengan TTL 15 detik (`abbey 15 IN A 10.99.99.99`) dan menaikkan serial SOA[cite: 1, 18].
- **Uji 3 Fase**:
  1. *Sebelum perubahan*: Query mengembalikan IP lama (`192.220.3.2`)[cite: 18, 21].
  2. *Sesaat setelah perubahan (< 15 detik)*: Query masih mengembalikan IP lama karena respon tersimpan di cache DNS[cite: 1, 18].
  3. *Setelah TTL habis (> 15 detik)*: Query berhasil memperbarui cache dan mengembalikan IP fiktif baru (`10.99.99.99`)[cite: 1, 18].
- **Restorasi**: Koordinat A record `abbey` dikembalikan ke IP normal (`192.220.3.2`) dan serial SOA dinaikkan kembali[cite: 1, 18, 21].

---

### Soal 19 — CNAME Internal ke External BadSSL (`soal_19.sh`, di prab)

- Menambahkan record CNAME pada file zona `/etc/bind/db.k18.com`: `outbound IN CNAME http.badssl.com.`[cite: 1, 19].
- Menaikkan serial SOA dan memuat ulang service BIND (`named`)[cite: 19].
- **Verifikasi**: Exec `dig @127.0.0.1 outbound.k18.com +short` mengembalikan `http.badssl.com.`[cite: 19]. Eksekusi `curl -sL http://outbound.k18.com` dari client berhasil menampilkan isi konten dari halaman BadSSL[cite: 1, 19].

---

### Soal 20 — Persistence & Autostart Configuration (`soal_20*.sh`, di seluruh node)

- Memastikan semua service, script pengalamatan, dan routing dapat berjalan kembali secara otomatis saat container/node di-restart[cite: 1]:
  - **rootkit (`soal_20_rootkit.sh`)**: Mengaktifkan IP forwarding (`net.ipv4.ip_forward=1`) dan aturan NAT MASQUERADE[cite: 15].
  - **prab & tedd (`soal_20_tedd.sh`)**: Memastikan direktori `/run/named` dibuat dengan *ownership* `bind:bind` dan daemon `named` berjalan[cite: 16].
  - **penny & abbey (`soal_20.sh`)**: Memastikan service Apache2, Nginx, dan PHP-FPM aktif[cite: 13, 20].
  - **vault & core (`soal_20_oblida.sh`, `soal_20_oblada.sh`)**: Memastikan daemon Nginx, Apache2, dan PHP-FPM berjalan[cite: 13, 14].
  - **client (`soal_20_alpha.sh`, `soal_20_beta.sh`)**: Memastikan urutan resolver `/etc/resolv.conf` tetap mengarah ke `192.220.5.2` (prab), `192.220.5.3` (tedd), lalu `192.168.122.1`[cite: 11, 12, 21].
