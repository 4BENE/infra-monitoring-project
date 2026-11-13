#!/bin/bash

LOG="access.log"
IPS=(192.168.1.10 192.168.1.11 192.168.1.12 10.0.0.5 10.0.0.6 10.0.0.7)
METHODS=(GET POST PUT DELETE)
URLS=(/api/users /api/login /api/orders /api/items)
CODES=(200 201 301 400 401 403 404 500 502 503)

: > "$LOG"
for i in $(seq 1 400); do
    ip=${IPS[$RANDOM % ${#IPS[@]}]}
    m=${METHODS[$RANDOM % ${#METHODS[@]}]}
    u=${URLS[$RANDOM % ${#URLS[@]}]}
    c=${CODES[$RANDOM % ${#CODES[@]}]}
    printf '%s - - [15/Aug/2026:10:%02d:%02d] "%s %s HTTP/1.1" %s\n' \
        "$ip" $((RANDOM % 60)) $((RANDOM % 60)) "$m" "$u" "$c" >> "$LOG"
done

echo "Общее количество запросов: $(wc -l < "$LOG")"

echo ""
echo "Топ-3 IP-адреса по числу запросов:"
grep -oE '^([0-9]{1,3}\.){3}[0-9]{1,3}' "$LOG" | sort | uniq -c | sort -rn | head -3

echo ""
echo "Запросов с кодами 4xx: $(awk '$NF ~ /^4[0-9][0-9]$/ {c++} END {print c+0}' "$LOG")"
echo "Запросов с кодами 5xx: $(awk '$NF ~ /^5[0-9][0-9]$/ {c++} END {print c+0}' "$LOG")"
