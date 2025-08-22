#!/bin/bash
# Validator Log Collection Script
# Collects logs from one server in each of the 5 AWS Core accounts
# Run this script from your local machine

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create logs directory
LOGS_DIR="validator_logs_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$LOGS_DIR"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  VALIDATOR LOG COLLECTION SCRIPT${NC}"
echo -e "${BLUE}======================================${NC}"
echo -e "Logs will be saved to: ${GREEN}$LOGS_DIR${NC}"
echo

# Function to collect logs from a server
collect_logs() {
    local account_name="$1"
    local account_id="$2"
    local ssh_key="$3"
    
    echo -e "${YELLOW}Connecting to ${account_name} (${account_id})...${NC}"
    
    # Create account-specific directory
    local account_dir="$LOGS_DIR/$account_name"
    mkdir -p "$account_dir"
    
    # Function to find the first available server in the account
    find_server() {
        # Try to find a server by checking common naming patterns
        # Since there are 15 validators per account, we'll try to find one consistently
        local server_found=""
        
        # Try different approaches to find a server
        # 1. Check if we can connect to a known pattern
        # 2. Use AWS CLI to list instances if available
        # 3. Try common naming conventions
        
        echo "Searching for available server in ${account_name}..."
        
        # For now, we'll need to establish connection through a known method
        # This could be through AWS Systems Manager, a bastion host, or direct connection
        # Since we can't determine the exact IP without more context, we'll create a template
        
        echo "⚠️  Server connection method needs to be configured"
        echo "   Options:"
        echo "   - AWS Systems Manager (SSM)"
        echo "   - Bastion host with port forwarding"
        echo "   - Direct connection if in same VPC"
        echo "   - Load balancer endpoint"
        
        return 1
    }
    
    # Try to find and connect to a server
    if find_server; then
        echo -e "${GREEN}Server found, collecting logs...${NC}"
        
        # SSH into server and collect logs (this would be the actual connection)
        # For now, we'll create a template of what would be collected
        
        echo "=== Template: What would be collected ==="
        echo "1. Server Information (hostname, date, uptime)"
        echo "2. Validator Services (systemctl status)"
        echo "3. Process Information (ps aux)"
        echo "4. Port 9651 Usage (lsof, netstat)"
        echo "5. Service Logs (journalctl)"
        echo "6. File-based Logs (/home/ubuntu/OdysseyGo/odysseygo/db/)"
        echo "7. Configuration Files"
        echo "8. Network Statistics"
        
        # Create a placeholder log file
        cat > "$account_dir/collection_template.txt" << EOF
=== ${account_name} Log Collection Template ===
Account ID: ${account_id}
Collection Date: $(date)
Status: Template Created - Manual Connection Required

To collect actual logs:
1. SSH into one of the 15 validator servers in this account
2. Run: sudo journalctl -u node-validator-{number} --since "2025-07-09 00:00:00" --until "2025-07-11 23:59:59"
3. Check logs in: /home/ubuntu/OdysseyGo/odysseygo/db/node{number}/logs
4. Verify service: /etc/systemd/system/node-validator-{number}.service

Expected findings based on cost spike:
- High network activity starting July 10, 2025
- Port 9651 traffic surge
- Validator sync processes consuming bandwidth
- Network connections to other validator nodes
EOF
        
        echo -e "${GREEN}Template created for ${account_name}${NC}"
    else
        echo -e "${RED}Could not establish connection to ${account_name}${NC}"
        echo "Creating connection guide..."
        
        cat > "$account_dir/connection_guide.txt" << EOF
=== ${account_name} Connection Guide ===
Account ID: ${account_id}

To connect to a validator server in this account:

Method 1: AWS Systems Manager (Recommended)
aws ssm start-session --target i-XXXXXXXXX --region us-east-1

Method 2: Direct SSH (if accessible)
ssh -i your-key.pem ubuntu@PRIVATE_IP

Method 3: Through Bastion Host
ssh -i your-key.pem -J ubuntu@BASTION_IP ubuntu@PRIVATE_IP

Method 4: Load Balancer (if configured)
ssh -i your-key.pem ubuntu@LOAD_BALANCER_DNS

Once connected, run the verification script:
./verify_port_9651.sh

Or collect logs manually:
sudo journalctl -u node-validator-1 --since "2025-07-09 00:00:00" --until "2025-07-11 23:59:59"
EOF
        
        echo -e "${YELLOW}Connection guide created for ${account_name}${NC}"
    fi
    
    echo
}

# Main execution
echo -e "${BLUE}Starting log collection...${NC}"
echo

# Configuration - You'll need to provide the SSH key path
SSH_KEY_PATH="${1:-/path/to/your/aws-key.pem}"

if [ ! -f "$SSH_KEY_PATH" ]; then
    echo -e "${RED}SSH key not found at: $SSH_KEY_PATH${NC}"
    echo -e "${YELLOW}Usage: $0 /path/to/your/ssh-key.pem${NC}"
    echo -e "${YELLOW}Or set the SSH_KEY_PATH environment variable${NC}"
    exit 1
fi

echo -e "${GREEN}Using SSH key: $SSH_KEY_PATH${NC}"
echo

# Collect logs from each AWS account
# Note: This will create templates/guides since we can't determine exact server IPs

echo -e "${YELLOW}Note: This script will create templates and connection guides.${NC}"
echo -e "${YELLOW}You'll need to manually connect to one server per account to collect actual logs.${NC}"
echo

# AWS Core Account 1
collect_logs "AWS-Core-1" "904233133784" "$SSH_KEY_PATH"

# AWS Core Account 2  
collect_logs "AWS-Core-2" "539247461227" "$SSH_KEY_PATH"

# AWS Core Account 3
collect_logs "AWS-Core-3" "296062550163" "$SSH_KEY_PATH"

# AWS Core Account 4
collect_logs "AWS-Core-4" "043309349217" "$SSH_KEY_PATH"

# AWS Core Account 5
collect_logs "AWS-Core-5" "850995569456" "$SSH_KEY_PATH"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  TEMPLATE CREATION COMPLETED${NC}"
echo -e "${BLUE}======================================${NC}"
echo -e "Templates and guides saved to: ${GREEN}$LOGS_DIR${NC}"
echo
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Review the connection guides in each account directory"
echo -e "2. Connect to one server per account using the provided methods"
echo -e "3. Run the verification script: ./verify_port_9651.sh"
echo -e "4. Collect actual logs using journalctl commands"
echo -e "5. Look for traffic patterns around July 10-11, 2025"
echo
echo -e "${BLUE}For immediate log collection, run:${NC}"
echo -e "${GREEN}./verify_port_9651.sh${NC}"
echo -e "on any of the validator servers"
