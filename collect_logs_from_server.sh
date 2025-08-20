#!/bin/bash
# Validator Log Collection Script - Run this ON the validator server
# This script collects all relevant logs and saves them locally

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create logs directory
LOGS_DIR="validator_logs_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$LOGS_DIR"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  VALIDATOR LOG COLLECTION SCRIPT${NC}"
echo -e "${BLUE}======================================${NC}"
echo -e "Logs will be saved to: ${GREEN}$LOGS_DIR${NC}"
echo

# Function to collect system information
collect_system_info() {
    echo -e "${YELLOW}Collecting system information...${NC}"
    
    cat > "$LOGS_DIR/system_info.txt" << EOF
=== System Information ===
Hostname: $(hostname)
Date: $(date)
Uptime: $(uptime)
Kernel: $(uname -r)
CPU: $(nproc) cores
Memory: $(free -h | grep Mem | awk '{print $2}')
Disk: $(df -h / | tail -1 | awk '{print $2}')
AWS Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "Not available")
AWS Region: $(curl -s http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null || echo "Not available")
EOF
    
    echo -e "${GREEN}✓ System information collected${NC}"
}

# Function to find validator services
find_validator_services() {
    echo -e "${YELLOW}Finding validator services...${NC}"
    
    cat > "$LOGS_DIR/validator_services.txt" << EOF
=== Validator Services ===
$(sudo systemctl list-units --type=service | grep node-validator || echo "No validator services found")

=== Service Files ===
$(find /etc/systemd/system -name "node-validator-*.service" 2>/dev/null | head -20 || echo "No validator service files found")

=== Active Services ===
$(for service in /etc/systemd/system/node-validator-*.service; do
    if [ -f "$service" ]; then
        service_name=$(basename "$service")
        echo "Service: $service_name"
        sudo systemctl is-active "$service_name" && echo "Status: ACTIVE" || echo "Status: INACTIVE"
        echo "---"
    fi
done 2>/dev/null || echo "No active services found")
EOF
    
    echo -e "${GREEN}✓ Validator services information collected${NC}"
}

# Function to collect process information
collect_process_info() {
    echo -e "${YELLOW}Collecting process information...${NC}"
    
    cat > "$LOGS_DIR/processes.txt" << EOF
=== Running Processes ===
$(ps aux | grep -E "(odysseygo|validator|node)" | grep -v grep || echo "No validator processes found")

=== Process Tree ===
$(pstree -p | grep -E "(odysseygo|validator|node)" || echo "No validator process tree found")

=== Memory Usage ===
$(ps aux | grep -E "(odysseygo|validator|node)" | grep -v grep | awk '{print $2, $3, $4, $11}' | head -10 || echo "No memory usage data")
EOF
    
    echo -e "${GREEN}✓ Process information collected${NC}"
}

# Function to check network usage
check_network_usage() {
    echo -e "${YELLOW}Checking network usage...${NC}"
    
    cat > "$LOGS_DIR/network_usage.txt" << EOF
=== Port 9651 Usage ===
$(sudo lsof -i :9651 2>/dev/null || echo "Port 9651 not in use")

=== Network Connections ===
$(sudo netstat -tulpn | grep 9651 || echo "No connections on port 9651")

=== Network Interface Statistics ===
$(cat /proc/net/dev | grep -E "(eth0|ens)" | head -2 || echo "Network interface stats not available")

=== Active Connections Summary ===
$(sudo netstat -an | grep ESTABLISHED | wc -l) total established connections
$(sudo netstat -an | grep :9651 | grep ESTABLISHED | wc -l) connections on port 9651
$(sudo netstat -an | grep :19999 | grep ESTABLISHED | wc -l) connections on port 19999
$(sudo netstat -an | grep :9650 | grep ESTABLISHED | wc -l) connections on port 9650
EOF
    
    echo -e "${GREEN}✓ Network usage information collected${NC}"
}

# Function to collect service logs
collect_service_logs() {
    echo -e "${YELLOW}Collecting service logs...${NC}"
    
    mkdir -p "$LOGS_DIR/service_logs"
    
    for service in /etc/systemd/system/node-validator-*.service; do
        if [ -f "$service" ]; then
            service_name=$(basename "$service" .service)
            echo "Collecting logs for: $service_name"
            
            # Collect recent logs (last 7 days)
            sudo journalctl -u "$service_name" --since "7 days ago" > "$LOGS_DIR/service_logs/${service_name}_recent.log" 2>&1 || echo "Failed to collect recent logs for $service_name"
            
            # Collect specific date range for cost spike
            sudo journalctl -u "$service_name" --since "2025-07-09 00:00:00" --until "2025-07-11 23:59:59" > "$LOGS_DIR/service_logs/${service_name}_cost_spike.log" 2>&1 || echo "Failed to collect cost spike logs for $service_name"
            
            # Collect today's logs
            sudo journalctl -u "$service_name" --since "today" > "$LOGS_DIR/service_logs/${service_name}_today.log" 2>&1 || echo "Failed to collect today's logs for $service_name"
            
            echo "  ✓ Logs collected for $service_name"
        fi
    done
    
    echo -e "${GREEN}✓ Service logs collected${NC}"
}

# Function to check file-based logs
check_file_logs() {
    echo -e "${YELLOW}Checking file-based logs...${NC}"
    
    mkdir -p "$LOGS_DIR/file_logs"
    
    if [ -d "/home/ubuntu/OdysseyGo/odysseygo/db" ]; then
        echo "Found OdysseyGo directory, checking for logs..."
        
        # Find all log directories
        find /home/ubuntu/OdysseyGo/odysseygo/db -name "logs" -type d > "$LOGS_DIR/file_logs/log_directories.txt" 2>/dev/null || echo "No log directories found"
        
        # Check each log directory
        while IFS= read -r log_dir; do
            if [ -d "$log_dir" ]; then
                dir_name=$(basename "$(dirname "$log_dir")")
                echo "Checking logs in: $dir_name"
                
                # List log files
                ls -la "$log_dir" > "$LOGS_DIR/file_logs/${dir_name}_log_files.txt" 2>/dev/null || echo "Could not list log files in $log_dir"
                
                # Collect recent log content (last 100 lines of each log file)
                for log_file in "$log_dir"/*.log; do
                    if [ -f "$log_file" ]; then
                        file_name=$(basename "$log_file")
                        tail -100 "$log_file" > "$LOGS_DIR/file_logs/${dir_name}_${file_name}_tail.txt" 2>/dev/null || echo "Could not read $log_file"
                    fi
                done
            fi
        done < "$LOGS_DIR/file_logs/log_directories.txt"
        
        echo -e "${GREEN}✓ File-based logs checked${NC}"
    else
        echo "OdysseyGo directory not found"
        echo "OdysseyGo directory not found" > "$LOGS_DIR/file_logs/status.txt"
    fi
}

# Function to check configuration
check_configuration() {
    echo -e "${YELLOW}Checking configuration...${NC}"
    
    mkdir -p "$LOGS_DIR/config"
    
    if [ -d "/home/ubuntu/OdysseyGo/odysseygo" ]; then
        # List configuration files
        ls -la /home/ubuntu/OdysseyGo/odysseygo/ > "$LOGS_DIR/config/odysseygo_directory.txt" 2>/dev/null || echo "Could not list OdysseyGo directory"
        
        # Check for specific config files
        find /home/ubuntu/OdysseyGo/odysseygo -name "*.conf" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" | head -20 > "$LOGS_DIR/config/config_files.txt" 2>/dev/null || echo "No config files found"
        
        # Check service configurations
        for service in /etc/systemd/system/node-validator-*.service; do
            if [ -f "$service" ]; then
                service_name=$(basename "$service")
                echo "=== $service_name ===" > "$LOGS_DIR/config/${service_name}_config.txt"
                cat "$service" >> "$LOGS_DIR/config/${service_name}_config.txt" 2>/dev/null || echo "Could not read $service"
            fi
        done
        
        echo -e "${GREEN}✓ Configuration information collected${NC}"
    else
        echo "OdysseyGo directory not found"
        echo "OdysseyGo directory not found" > "$LOGS_DIR/config/status.txt"
    fi
}

# Function to capture live traffic
capture_live_traffic() {
    echo -e "${YELLOW}Capturing live traffic...${NC}"
    
    mkdir -p "$LOGS_DIR/traffic_capture"
    
    # Capture traffic on port 9651 for 30 seconds
    echo "Capturing traffic on port 9651 for 30 seconds..."
    timeout 30 sudo tcpdump -i any port 9651 -nn -c 1000 > "$LOGS_DIR/traffic_capture/port_9651_capture.txt" 2>&1 || echo "Traffic capture failed or no traffic on port 9651"
    
    # Count packets
    PACKET_COUNT=$(wc -l < "$LOGS_DIR/traffic_capture/port_9651_capture.txt" 2>/dev/null || echo "0")
    echo "Captured $PACKET_COUNT packets on port 9651"
    
    # Network interface stats
    cat /proc/net/dev | grep -E "(eth0|ens)" > "$LOGS_DIR/traffic_capture/network_stats.txt" 2>/dev/null || echo "Network stats not available"
    
    echo -e "${GREEN}✓ Live traffic captured${NC}"
}

# Function to create summary report
create_summary() {
    echo -e "${YELLOW}Creating summary report...${NC}"
    
    cat > "$LOGS_DIR/SUMMARY_REPORT.txt" << EOF
=======================================
VALIDATOR LOG COLLECTION SUMMARY
=======================================
Collection Date: $(date)
Hostname: $(hostname)
Logs Directory: $LOGS_DIR

=== Collection Status ===
✓ System Information
✓ Validator Services
✓ Process Information
✓ Network Usage
✓ Service Logs
✓ File-based Logs
✓ Configuration
✓ Live Traffic Capture

=== Key Findings ===
$(if [ -f "$LOGS_DIR/validator_services.txt" ]; then
    echo "Validator Services:"
    grep -c "node-validator" "$LOGS_DIR/validator_services.txt" 2>/dev/null || echo "Unknown"
    echo
fi)

$(if [ -f "$LOGS_DIR/network_usage.txt" ]; then
    echo "Network Activity:"
    grep "connections on port 9651" "$LOGS_DIR/network_usage.txt" 2>/dev/null || echo "Port 9651 connections: Unknown"
    echo
fi)

$(if [ -f "$LOGS_DIR/traffic_capture/port_9651_capture.txt" ]; then
    echo "Traffic Capture:"
    PACKET_COUNT=$(wc -l < "$LOGS_DIR/traffic_capture/port_9651_capture.txt" 2>/dev/null || echo "0")
    echo "Packets captured on port 9651: $PACKET_COUNT"
    echo
fi)

=== Next Steps ===
1. Review the collected logs for patterns around July 10-11, 2025
2. Look for traffic spikes and network activity
3. Check validator sync status and peer connections
4. Analyze correlation with AWS cost spike
5. Run verification script: ./verify_port_9651.sh

=== Files Collected ===
$(find "$LOGS_DIR" -type f | wc -l) total files
$(du -sh "$LOGS_DIR" 2>/dev/null || echo "Size: Unknown")

=======================================
EOF
    
    echo -e "${GREEN}✓ Summary report created${NC}"
}

# Main execution
echo -e "${BLUE}Starting comprehensive log collection...${NC}"
echo

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Note: Some commands require sudo privileges${NC}"
    echo -e "${YELLOW}Consider running with: sudo $0${NC}"
    echo
fi

# Collect all information
collect_system_info
find_validator_services
collect_process_info
check_network_usage
collect_service_logs
check_file_logs
check_configuration
capture_live_traffic
create_summary

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  LOG COLLECTION COMPLETED${NC}"
echo -e "${BLUE}======================================${NC}"
echo -e "All logs saved to: ${GREEN}$LOGS_DIR${NC}"
echo
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Review the summary report: $LOGS_DIR/SUMMARY_REPORT.txt"
echo -e "2. Check service logs for July 10-11 activity"
echo -e "3. Analyze network traffic patterns"
echo -e "4. Look for validator sync and peer connection logs"
echo -e "5. Correlate findings with AWS cost spike data"
echo
echo -e "${BLUE}To transfer logs to your local machine:${NC}"
echo -e "${GREEN}scp -r $LOGS_DIR user@your-local-machine:/path/to/destination${NC}"
