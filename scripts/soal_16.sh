#!/bin/bash
# SOAL 16: Stress test benchmark menggunakan ApacheBench (ab)
which ab >/dev/null 2>&1 || (apt-get update -qq && apt-get install -y -qq apache2-utils)

echo "=========================================================="
echo " BENCHMARK 1: http://www.k18.com/ (Penny -> Vault)"
echo " 250 requests, concurrency 10"
echo "=========================================================="
ab -n 250 -c 10 http://www.k18.com/ > /tmp/ab_penny.log
grep -E "Server Software|Complete requests|Failed requests|Requests per second|Time per request" /tmp/ab_penny.log

echo ""
echo "=========================================================="
echo " BENCHMARK 2: http://static.k18.com/ (Abbey -> Core)"
echo " 250 requests, concurrency 10"
echo "=========================================================="
ab -n 250 -c 10 http://static.k18.com/ > /tmp/ab_abbey.log
grep -E "Server Software|Complete requests|Failed requests|Requests per second|Time per request" /tmp/ab_abbey.log
