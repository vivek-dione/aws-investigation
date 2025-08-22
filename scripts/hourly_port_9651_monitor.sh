#!/bin/bash
# Hourly Port 9651 Outbound Traffic Monitor
# Run this on a validator server to monitor outbound data usage over 1-hour periods
# Usage: ./hourly_port_9651_monitor.sh

echo "======================================="
echo "  PORT 9651 HOURLY TRAFFIC MONITOR"
echo "======================================="
echo "Monitoring outbound traffic on port 9651 over 1-hour periods"
echo "Press Ctrl+C to stop monitoring"
echo

# Create output file
OUTPUT_FILE="port_9651_hourly_$(date +%Y%m%d_%H%M%S).log"
echo "Hour_Start,Hour_End,Total_Data_Consumed_MB,Total_Data_Consumed_GB,Avg_Rate_KB_per_min,Max_Connections,Min_Connections" > "$OUTPUT_FILE"

echo "Hour Start | Hour End | Data Consumed | Avg Rate | Connections (min-max)"
echo "------------------------------------------------------------------------"

# Initialize counters
last_tx=0
hour_start_tx=0
hour_start_time=$(date '+%Y-%m-%d %H:%M:%S')
hour_counter=0
max_connections=0
min_connections=999

while true; do
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Get interface TX bytes (outbound data)
    interface_tx=$(cat /sys/class/net/ens5/statistics/tx_bytes 2>/dev/null || echo "0")
    
    # Get number of active connections on port 9651
    port_connections=$(ss -t -n | grep ":9651" | grep -v "LISTEN" | wc -l)
    
    # Track min/max connections for this hour
    if [ "$port_connections" -gt "$max_connections" ]; then
        max_connections=$port_connections
    fi
    if [ "$port_connections" -lt "$min_connections" ] && [ "$port_connections" -gt 0 ]; then
        min_connections=$port_connections
    fi
    
    # Initialize hour start values
    if [ "$hour_counter" -eq 0 ]; then
        hour_start_tx=$interface_tx
        hour_start_time=$timestamp
        max_connections=$port_connections
        min_connections=$port_connections
    fi
    
    # Every hour (3600 seconds), calculate cumulative consumption
    if [ $((hour_counter % 3600)) -eq 0 ] && [ "$hour_counter" -gt 0 ]; then
        hour_end_time=$timestamp
        
        # Calculate total data consumed in this hour
        data_consumed=$((interface_tx - hour_start_tx))
        data_consumed_mb=$((data_consumed / 1024 / 1024))
        data_consumed_gb=$((data_consumed / 1024 / 1024 / 1024))
        
        # Calculate average rate over the hour
        avg_rate_kb_per_min=$((data_consumed_mb * 1024 / 60))  # KB per minute
        
        # Display hour summary
        echo "$hour_start_time | $hour_end_time | ${data_consumed_mb} MB (${data_consumed_gb} GB) | ${avg_rate_kb_per_min} KB/min | $min_connections-$max_connections"
        
        # Save to CSV
        echo "$hour_start_time,$hour_end_time,$data_consumed_mb,$data_consumed_gb,$avg_rate_kb_per_min,$max_connections,$min_connections" >> "$OUTPUT_FILE"
        
        # Reset for next hour
        hour_start_tx=$interface_tx
        hour_start_time=$timestamp
        max_connections=$port_connections
        min_connections=$port_connections
    fi
    
    # Show current status every 5 minutes
    if [ $((hour_counter % 300)) -eq 0 ]; then
        current_rate=$((interface_tx - last_tx))
        current_rate_kb=$((current_rate / 1024))
        echo "[$timestamp] Current rate: ${current_rate_kb} KB/s | Connections: $port_connections | Hour: $((hour_counter / 3600))h $(((hour_counter % 3600) / 60))m"
    fi
    
    # Update last value and counter
    last_tx=$interface_tx
    hour_counter=$((hour_counter + 1))
    
    # Wait 1 second
    sleep 1
done
