#!/bin/bash
# Step 3: Extract real IP addresses from the '[' connections
# This script reveals the actual IP addresses behind the display issue

echo "=== STEP 3: EXTRACTING REAL IP ADDRESSES ==="
echo "Time: $(date)"
echo

echo "1. ALL UNIQUE SOURCE IPs CONNECTING TO PORT 9651:"
ss -t -n | grep ":9651" | grep -v "LISTEN" | awk '{print $5}' | sed 's/\[::ffff://g' | sed 's/\]//g' | cut -d: -f1 | sort | uniq -c | sort -nr

echo
echo "2. CONNECTION COUNT BY SOURCE IP:"
ss -t -n | grep ":9651" | grep -v "LISTEN" | awk '{print $5}' | sed 's/\[::ffff://g' | sed 's/\]//g' | cut -d: -f1 | sort | uniq -c | sort -nr

echo
echo "3. TOP 10 SOURCE IPs BY CONNECTION COUNT:"
ss -t -n | grep ":9651" | grep -v "LISTEN" | awk '{print $5}' | sed 's/\[::ffff://g' | sed 's/\]//g' | cut -d: -f1 | sort | uniq -c | sort -nr | head -10

echo
echo "4. GEOGRAPHIC DISTRIBUTION CHECK:"
echo "Checking if connections are from expected regions..."
ss -t -n | grep ":9651" | grep -v "LISTEN" | awk '{print $5}' | sed 's/\[::ffff://g' | sed 's/\]//g' | cut -d: -f1 | sort | uniq | while read IP; do
    if [ ! -z "$IP" ]; then
        echo "  $IP"
    fi
done
