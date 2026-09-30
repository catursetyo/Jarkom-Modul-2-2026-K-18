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
