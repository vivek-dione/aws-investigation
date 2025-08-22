#!/bin/bash
# Port 9651 Outbound Traffic Monitor
# Run this on a validator server to monitor outbound data usage
# Usage: ./monitor_port_9651_traffic.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create monitoring directory
MONITOR_DIR="port_9651_monitoring_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$MONITOR_DIR"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  PORT 9651 TRAFFIC MONITOR${NC}"
echo -e "${BLUE}======================================${NC}"
echo -e "Monitoring outbound traffic on port 9651"
echo -e "Data will be saved to: ${GREEN}$MONITOR_DIR${NC}"
echo -e "Press Ctrl+C to stop monitoring"
echo

# Function to get current timestamp
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Function to get current outbound bytes on port 9651
get_port_9651_outbound() {
    # Get outbound bytes for port 9651 using ss command
    local outbound_bytes=$(ss -i -n | grep ":9651" | grep -v "LISTEN" | awk '{sum += $2} END {print sum+0}')
    echo "${outbound_bytes:-0}"
}

# Function to get network interface stats for ens5 (AWS default)
get_interface_stats() {
    local interface="ens5"
    if [ ! -d "/sys/class/net/$interface" ]; then
        # Try to find the correct interface
        interface=$(ip route | grep default | awk '{print $5}' | head -1)
    fi
    
    if [ -n "$interface" ]; then
        local rx_bytes=$(cat "/sys/class/net/$interface/statistics/rx_bytes" 2>/dev/null || echo "0")
        local tx_bytes=$(cat "/sys/class/net/$interface/statistics/tx_bytes" 2>/dev/null || echo "0")
        echo "$rx_bytes $tx_bytes"
    else
        echo "0 0"
    fi
}

# Function to get process-specific network usage for odysseygo
get_process_network_usage() {
    local odysseygo_pid=$(pgrep odysseygo | head -1)
    if [ -n "$odysseygo_pid" ]; then
        # Get network stats for the odysseygo process
        local net_stats=$(cat "/proc/$odysseygo_pid/net/dev" 2>/dev/null | grep -E "(ens5|eth0)" | awk '{print $2, $10}')
        echo "$net_stats"
    else
        echo "0 0"
    fi
}

# Main monitoring loop
echo -e "${YELLOW}Starting monitoring at $(get_timestamp)${NC}"
echo -e "${GREEN}Timestamp | Port 9651 Outbound | Interface TX | Process TX | Total Outbound${NC}"
echo "--------------------------------------------------------------------------------"

# Create CSV file for data export
CSV_FILE="$MONITOR_DIR/traffic_data.csv"
echo "Timestamp,Port_9651_Outbound,Interface_TX,Process_TX,Total_Outbound" > "$CSV_FILE"

# Initialize counters
last_interface_tx=0
last_process_tx=0
last_port_outbound=0

while true; do
    timestamp=$(get_timestamp)
    
    # Get current stats
    port_outbound=$(get_port_9651_outbound)
    interface_stats=$(get_interface_stats)
    interface_rx=$(echo "$interface_stats" | awk '{print $1}')
    interface_tx=$(echo "$interface_stats" | awk '{print $2}')
    
    process_stats=$(get_process_network_usage)
    process_rx=$(echo "$process_stats" | awk '{print $1}')
    process_tx=$(echo "$process_stats" | awk '{print $2}')
    
    # Calculate deltas (bytes per second)
    if [ "$last_interface_tx" -gt 0 ]; then
        interface_tx_delta=$((interface_tx - last_interface_tx))
        process_tx_delta=$((process_tx - last_process_tx))
        port_outbound_delta=$((port_outbound - last_port_outbound))
        
        # Convert to human readable
        interface_tx_delta_hr=$(numfmt --to=iec $interface_tx_delta)
        process_tx_delta_hr=$(numfmt --to=iec $process_tx_delta)
        port_outbound_delta_hr=$(numfmt --to=iec $port_outbound_delta)
        
        echo -e "${GREEN}$timestamp${NC} | ${YELLOW}$port_outbound_delta_hr/s${NC} | ${BLUE}$interface_tx_delta_hr/s${NC} | ${RED}$process_tx_delta_hr/s${NC} | ${GREEN}$((interface_tx_delta + process_tx_delta)) bytes/s${NC}"
        
        # Save to CSV
        echo "$timestamp,$port_outbound_delta,$interface_tx_delta,$process_tx_delta,$((interface_tx_delta + process_tx_delta))" >> "$CSV_FILE"
    else
        echo -e "${GREEN}$timestamp${NC} | ${YELLOW}Initializing...${NC} | ${BLUE}Initializing...${NC} | ${RED}Initializing...${NC} | ${GREEN}Initializing...${NC}"
    fi
    
    # Update last values
    last_interface_tx=$interface_tx
    last_process_tx=$process_tx
    last_port_outbound=$port_outbound
    
    # Wait 1 second
    sleep 1
done
