  GNU nano 7.2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         scan_devices.sh
#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -euo pipefail

INTERFACE="wlan0"
NETWORK="192.168.0.0/24"
ELASTIC_URL="http://127.0.0.1:9200"
INDEX="network-devices"
DOWN_AFTER="10m"
WHITELIST_FILE="/home/sns/whitelist.txt"

ARP_SCAN="/usr/sbin/arp-scan"
ARP_OUI_FILE="/usr/share/arp-scan/ieee-oui.txt"
ARP_MAC_FILE="/etc/arp-scan/mac-vendor.txt"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SCANNER_HOST=$(hostname)
LOCAL_IP=$(ip -4 addr show "$INTERFACE" | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)
LOCAL_MAC=$(cat "/sys/class/net/$INTERFACE/address" 2>/dev/null || echo "")
LOCAL_HOSTNAME=$(hostname)

get_whitelist_entry() {
    local mac="$1"

    if [ ! -f "$WHITELIST_FILE" ]; then
        return 1
    fi

    awk -F'|' -v target="$mac" '
    BEGIN { IGNORECASE=1 }
    /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
    {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $3)

        mac=tolower($1)
        if (mac == tolower(target)) {
            printf "%s|%s\n", $2, $3
            exit 0
        }
    }' "$WHITELIST_FILE"
}

index_device() {
    local ts="$1"
    local first_seen="$2"
    local last_seen="$3"
    local scanner_host="$4"
    local interface="$5"
    local ip="$6"
    local mac="$7"
    local vendor="$8"
    local hostname="$9"
    local whitelist_status="${10}"
    local whitelisted="${11}"
    local device_name="${12}"
    local notes="${13}"

    jq -n \
      --arg ts "$ts" \
      --arg first_seen "$first_seen" \
      --arg last_seen "$last_seen" \
      --arg scanner_host "$scanner_host" \
      --arg interface "$interface" \
      --arg ip "$ip" \
      --arg mac "$mac" \
      --arg vendor "$vendor" \
      --arg hostname "$hostname" \
      --arg whitelist_status "$whitelist_status" \
      --arg device_name "$device_name" \
      --arg notes "$notes" \
      --argjson whitelisted "$whitelisted" \
      '{
        "@timestamp": $ts,
        "first_seen": $first_seen,
        "last_seen": $last_seen,
        "scanner_host": $scanner_host,
        "interface": $interface,
        "ip": $ip,
        "mac": $mac,
        "vendor": $vendor,
        "hostname": $hostname,
        "status": "up",
        "whitelisted": $whitelisted,
        "whitelist_status": $whitelist_status,
        "device_name": $device_name,
        "notes": $notes
      }' | \
    curl -s -X PUT "$ELASTIC_URL/$INDEX/_doc/$mac" \
         -H "Content-Type: application/json" \
         -d @- > /dev/null
}

sudo "$ARP_SCAN" \
    --interface="$INTERFACE" \
    --ouifile="$ARP_OUI_FILE" \
    --macfile="$ARP_MAC_FILE" \
    "$NETWORK" 2>/dev/null | \
awk -v ts="$TIMESTAMP" -v host="$SCANNER_HOST" -v iface="$INTERFACE" '
/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+[[:space:]]+([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}/ {
    ip=$1
    mac=tolower($2)

    vendor=""
    for (i=3; i<=NF; i++) {
        vendor = vendor $i
        if (i < NF) vendor = vendor " "
    }

    gsub(/"/, "\\\"", vendor)
    sub(/[[:space:]]+\(DUP:.*\)$/, "", vendor)

    printf("%s|%s|%s|%s|%s|%s\n", ip, mac, vendor, ts, host, iface)
}
' | while IFS='|' read -r ip mac vendor ts host iface; do

    mac=$(echo "$mac" | tr 'A-F' 'a-f')

    hostname_result=$(getent hosts "$ip" | awk '{print $2}' | head -n1 || true)
    if [ -z "${hostname_result:-}" ]; then
        hostname_result=""
    fi

    device_name=""
    notes=""

    whitelist_entry=$(get_whitelist_entry "$mac" || true)
    if [ -n "${whitelist_entry:-}" ]; then
        whitelisted="true"
        whitelist_status="approved"
        IFS='|' read -r device_name notes <<< "$whitelist_entry"
    else
        whitelisted="false"
        whitelist_status="unknown"
    fi

    existing_doc=$(curl -s "$ELASTIC_URL/$INDEX/_doc/$mac" || true)
    found=$(echo "$existing_doc" | jq -r '.found // false' 2>/dev/null || echo "false")

    if [ "$found" = "true" ]; then
        first_seen=$(echo "$existing_doc" | jq -r '._source.first_seen // empty' 2>/dev/null || true)
    else
        first_seen=""
    fi

    if [ -z "${first_seen:-}" ] || [ "$first_seen" = "null" ]; then
        first_seen="$ts"
    fi

    index_device \
        "$ts" \
        "$first_seen" \
        "$ts" \
        "$host" \
        "$iface" \
        "$ip" \
        "$mac" \
        "$vendor" \
        "$hostname_result" \
        "$whitelist_status" \
        "$whitelisted" \
        "$device_name" \
        "$notes"
done

if [ -n "${LOCAL_IP:-}" ] && [ -n "${LOCAL_MAC:-}" ]; then
    local_mac=$(echo "$LOCAL_MAC" | tr 'A-F' 'a-f')

    device_name=""
    notes=""

    whitelist_entry=$(get_whitelist_entry "$local_mac" || true)
    if [ -n "${whitelist_entry:-}" ]; then
        whitelisted="true"
        whitelist_status="approved"
        IFS='|' read -r device_name notes <<< "$whitelist_entry"
    else
        whitelisted="false"
        whitelist_status="unknown"
    fi

    existing_doc=$(curl -s "$ELASTIC_URL/$INDEX/_doc/$local_mac" || true)
    found=$(echo "$existing_doc" | jq -r '.found // false' 2>/dev/null || echo "false")

    if [ "$found" = "true" ]; then
        first_seen=$(echo "$existing_doc" | jq -r '._source.first_seen // empty' 2>/dev/null || true)
    else
        first_seen=""
    fi

    if [ -z "${first_seen:-}" ] || [ "$first_seen" = "null" ]; then
        first_seen="$TIMESTAMP"
    fi

    index_device \
        "$TIMESTAMP" \
        "$first_seen" \
        "$TIMESTAMP" \
        "$SCANNER_HOST" \
        "$INTERFACE" \
        "$LOCAL_IP" \
        "$local_mac" \
        "Local Scanner" \
        "$LOCAL_HOSTNAME" \
        "$whitelist_status" \
        "$whitelisted" \
        "$device_name" \
        "$notes"
fi

curl -s -X POST "$ELASTIC_URL/$INDEX/_update_by_query?refresh=true" \
     -H "Content-Type: application/json" \
     -d "{
       \"script\": {
         \"source\": \"ctx._source.status = 'down'\",
         \"lang\": \"painless\"
       },
       \"query\": {
         \"range\": {
           \"last_seen\": {
             \"lt\": \"now-$DOWN_AFTER\"
           }
         }
       }
     }" > /dev/null

echo "Scan complete for $NETWORK on $INTERFACE at $TIMESTAMP"







































































