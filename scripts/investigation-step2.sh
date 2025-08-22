#!/bin/bash
# Step 2: Deep dive into the mysterious '[' connections
# This script investigates the '[' connections to understand what they really are

echo "=== STEP 2: INVESTIGATING '[' CONNECTIONS ==="
echo "Time: $(date)"
echo

echo "1. DETAILED CONNECTION INFO FOR '[' CONNECTIONS:"
ss -t -n -p | grep ":9651" | grep -v "LISTEN" | grep "\[" | head -5

echo
echo "2. PROCESS INFORMATION FOR THESE CONNECTIONS:"
ss -t -n -p | grep ":9651" | grep -v "LISTEN" | grep "\[" | awk '{print $7}' | head -5

echo
echo "3. NETSTAT OUTPUT (alternative view):"
if command -v netstat >/dev/null 2>&1; then
    netstat -t -n -p | grep ":9651" | grep -v "LISTEN" | head -5
else
    echo "netstat command not found, using ss instead:"
    ss -t -n -i | grep ":9651" | grep -v "LISTEN" | head -3
fi

echo
echo "4. CHECKING IF '[' IS A DISPLAY ISSUE:"
ss -t -n -i | grep ":9651" | grep -v "LISTEN" | head -3

echo
echo "5. TCPDUMP QUICK CHECK (last 10 packets):"
if command -v tcpdump >/dev/null 2>&1; then
    sudo tcpdump -i ens5 -n port 9651 -c 10 2>/dev/null | head -5
else
    echo "tcpdump command not found"
fi
