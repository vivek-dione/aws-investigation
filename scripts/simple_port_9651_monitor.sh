#!/bin/bash
# Simple Port 9651 Outbound Traffic Monitor
# Run this on a validator server to monitor outbound data usage over 5-minute periods
# Usage: ./simple_port_9651_monitor.sh

echo "======================================="
echo "  PORT 9651 OUTBOUND TRAFFIC MONITOR"
echo "======================================="
echo "Monitoring outbound traffic on port 9651 over 5-minute periods"
echo "Press Ctrl+C to stop monitoring"
echo

# Create output file
OUTPUT_FILE="port_9651_traffic_$(date +%Y%m%d_%H%M%S).log"
echo "Timestamp,Period_Start,Period_End,Interface_TX_Bytes,Port_9651_Connections,Data_Consumed_5min,Data_Consumed_5min_KB,Data_Consumed_5min_MB" > "$OUTPUT_FILE"

echo "Period Start | Period End | Data Consumed (5min) | Avg Rate | Connections"
echo "------------------------------------------------------------------------"

# Initialize counters
last_tx=0
period_start_tx=0
period_start_time=$(date '+%Y-%m-%d %H:%M:%S')
period_counter=0

while true; do
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Get interface TX bytes (outbound data)
    interface_tx=$(cat /sys/class/net/ens5/statistics/tx_bytes 2>/dev/null || echo "0")
    
    # Get number of active connections on port 9651
    port_connections=$(ss -t -n | grep ":9651" | grep -v "LISTEN" | wc -l)
    
    # Initialize period start values
    if [ "$period_counter" -eq 0 ]; then
        period_start_tx=$interface_tx
        period_start_time=$timestamp
    fi
    
    # Calculate data rate (bytes per second) for real-time display
    if [ "$last_tx" -gt 0 ]; then
        current_rate=$((interface_tx - last_tx))
        current_rate_kb=$((current_rate / 1024))
    else
        current_rate_kb=0
    fi
    
    # Every 5 minutes (300 seconds), calculate cumulative consumption
    if [ $((period_counter % 300)) -eq 0 ] && [ "$period_counter" -gt 0 ]; then
        period_end_time=$timestamp
        
        # Calculate total data consumed in this 5-minute period
        data_consumed=$((interface_tx - period_start_tx))
        data_consumed_kb=$((data_consumed / 1024))
        data_consumed_mb=$((data_consumed / 1024 / 1024))
        
        # Calculate average rate over the period
        avg_rate_kb=$((data_consumed_kb / 5))  # KB per minute
        
        # Display period summary
        echo "$period_start_time | $period_end_time | ${data_consumed_mb} MB (${data_consumed_kb} KB) | ${avg_rate_kb} KB/min | $port_connections connections"
        
        # Save to CSV
        echo "$timestamp,$period_start_time,$period_end_time,$interface_tx,$port_connections,$data_consumed,$data_consumed_kb,$data_consumed_mb" >> "$OUTPUT_FILE"
        
        # Reset for next period
        period_start_tx=$interface_tx
        period_start_time=$timestamp
    fi
    
    # Show current status every 30 seconds
    if [ $((period_counter % 30)) -eq 0 ]; then
        echo "[$timestamp] Current rate: ${current_rate_kb} KB/s | Connections: $port_connections | Period: $((period_counter / 60))m $((period_counter % 60))s"
    fi
    
    # Update last value and counter
    last_tx=$interface_tx
    period_counter=$((period_counter + 1))
    
    # Wait 1 second
    sleep 1
done
