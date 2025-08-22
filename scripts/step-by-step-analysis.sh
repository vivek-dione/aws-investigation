#!/bin/bash
# Step-by-step connection analysis for port 9651
# This script provides a clean analysis of connections to help identify issues

echo "=== STEP 1: CLEAN CONNECTION ANALYSIS ==="
echo "Time: $(date)"
echo

echo "1. TOTAL CONNECTIONS TO PORT 9651:"
TOTAL_CONN=$(ss -t -n | grep ":9651" | grep -v "LISTEN" | wc -l)
echo "   Total: $TOTAL_CONN connections"
echo

echo "2. BREAKDOWN BY CONNECTION TYPE:"
echo "   Legitimate IP connections:"
ss -t -n | grep ":9651" | grep -v "LISTEN" | grep -E "^ESTAB" | awk '{print "     " $5}' | cut -d: -f1 | sort | uniq -c | sort -nr

echo "   Malformed connections:"
ss -t -n | grep ":9651" | grep -v "LISTEN" | grep -v -E "^ESTAB" | wc -l
echo

echo "3. NETWORK INTERFACE STATS:"
RX_BYTES=$(cat /sys/class/net/ens5/statistics/rx_bytes 2>/dev/null || echo "0")
TX_BYTES=$(cat /sys/class/net/ens5/statistics/tx_bytes 2>/dev/null || echo "0")
echo "   RX (incoming): $((RX_BYTES / 1024 / 1024)) MB"
echo "   TX (outgoing): $((TX_BYTES / 1024 / 1024)) MB"
echo

echo "4. CONNECTION STATES:"
ss -t -n | grep ":9651" | grep -v "LISTEN" | awk '{print $1}' | sort | uniq -c
