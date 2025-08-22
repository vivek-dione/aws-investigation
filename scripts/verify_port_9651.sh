#!/bin/bash
# Port 9651 Traffic Verification Script
# Run this on EC2 instance via SSH

echo "========================================"
echo "PORT 9651 TRAFFIC VERIFICATION SCRIPT"
echo "Instance: $(hostname)"
echo "Date: $(date)"
echo "========================================"
echo

# Step 1: Check if port 9651 is active
echo "1. Checking if port 9651 is in use..."
PROCESS_9651=$(sudo lsof -i :9651)
if [ -z "$PROCESS_9651" ]; then
    echo "❌ NO PROCESS found using port 9651"
else
    echo "✅ PROCESS FOUND on port 9651:"
    echo "$PROCESS_9651"
fi
echo

# Step 2: Check network connections on port 9651
echo "2. Checking active connections on port 9651..."
CONNECTIONS_9651=$(sudo netstat -tulpn | grep 9651)
if [ -z "$CONNECTIONS_9651" ]; then
    echo "❌ NO CONNECTIONS found on port 9651"
else
    echo "✅ CONNECTIONS FOUND on port 9651:"
    echo "$CONNECTIONS_9651"
fi
echo

# Step 3: Check all listening ports
echo "3. All listening ports on this instance:"
sudo netstat -tulpn | grep LISTEN | head -10
echo

# Step 4: Check validator-related processes
echo "4. Checking for validator/sync processes..."
VALIDATOR_PROC=$(ps aux | grep -i -E "(validator|sync)" | grep -v grep)
if [ -z "$VALIDATOR_PROC" ]; then
    echo "❌ NO validator/sync processes found"
else
    echo "✅ VALIDATOR/SYNC PROCESSES found:"
    echo "$VALIDATOR_PROC"
fi
echo

# Step 5: Check network interface statistics
echo "5. Current network interface statistics:"
cat /proc/net/dev | grep -E "(eth0|ens)" | head -2
echo

# Step 6: Capture live traffic on port 9651 for 30 seconds
echo "6. Capturing live traffic on port 9651 for 30 seconds..."
echo "Starting packet capture..."
PACKET_COUNT=$(timeout 30 sudo tcpdump -i any port 9651 -nn 2>/dev/null | wc -l)
echo "✅ Captured $PACKET_COUNT packets on port 9651 in 30 seconds"

# Calculate packets per hour
PACKETS_PER_HOUR=$((PACKET_COUNT * 120))
echo "📊 Projected packets per hour: $PACKETS_PER_HOUR"
echo

# Step 7: Check Netdata (should be on port 19999)
echo "7. Checking Netdata process and port..."
NETDATA_PROC=$(ps aux | grep netdata | grep -v grep)
NETDATA_PORT=$(sudo netstat -tulpn | grep 19999)

if [ -z "$NETDATA_PROC" ]; then
    echo "❌ Netdata process not found"
else
    echo "✅ Netdata process found:"
    echo "$NETDATA_PROC" | head -2
fi

if [ -z "$NETDATA_PORT" ]; then
    echo "❌ Netdata port 19999 not listening"
else
    echo "✅ Netdata port 19999 active:"
    echo "$NETDATA_PORT"
fi
echo

# Step 8: Summary and verdict
echo "========================================"
echo "VERIFICATION SUMMARY"
echo "========================================"

if [ -n "$PROCESS_9651" ] && [ $PACKET_COUNT -gt 10 ]; then
    echo "🎯 VERDICT: Port 9651 IS LIKELY THE CULPRIT"
    echo "   - Process found on port 9651"
    echo "   - Active traffic detected ($PACKET_COUNT packets/30sec)"
    echo "   - Projected high traffic volume"
elif [ -z "$PROCESS_9651" ]; then
    echo "❌ VERDICT: Port 9651 is NOT the culprit"
    echo "   - No process using port 9651"
    echo "   - Need to investigate other traffic sources"
elif [ $PACKET_COUNT -le 10 ]; then
    echo "🤔 VERDICT: Port 9651 has low traffic"
    echo "   - Process exists but minimal traffic"
    echo "   - May not be primary cost driver"
fi

echo
echo "Next steps:"
echo "- If port 9651 IS the culprit: investigate validator sync configuration"
echo "- If port 9651 is NOT the culprit: run 'sudo iftop -P' to find high-traffic ports"
echo "========================================"