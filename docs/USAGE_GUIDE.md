# Validator Log Collection Usage Guide

## Overview
This guide explains how to collect validator logs from your AWS servers to investigate the July 10-11, 2025 cost spike.

## Quick Start

### Option 1: Run on Each Server (Recommended)
1. **SSH into one validator server from each AWS account**
2. **Upload the collection script:**
   ```bash
   scp collect_logs_from_server.sh ubuntu@SERVER_IP:/home/ubuntu/
   ```
3. **Run the script on the server:**
   ```bash
   ssh ubuntu@SERVER_IP
   cd /home/ubuntu
   chmod +x collect_logs_from_server.sh
   sudo ./collect_logs_from_server.sh
   ```
4. **Download the logs to your local machine:**
   ```bash
   scp -r ubuntu@SERVER_IP:/home/ubuntu/validator_logs_* /local/path/
   ```

### Option 2: Use the Verification Script
1. **Upload the verification script:**
   ```bash
   scp verify_port_9651.sh ubuntu@SERVER_IP:/home/ubuntu/
   ```
2. **Run it on the server:**
   ```bash
   ssh ubuntu@SERVER_IP
   cd /home/ubuntu
   chmod +x verify_port_9651.sh
   sudo ./verify_port_9651.sh
   ```

## What Gets Collected

### System Information
- Hostname, date, uptime
- AWS instance details
- System resources

### Validator Services
- Service status and configuration
- Active validator processes
- Service files

### Network Activity
- Port 9651 usage and connections
- Network interface statistics
- Live traffic capture (30 seconds)

### Logs
- **Service logs:** `journalctl -u node-validator-{number}`
- **File logs:** `/home/ubuntu/OdysseyGo/odysseygo/db/node{number}/logs`
- **Cost spike period:** July 9-11, 2025
- **Recent logs:** Last 7 days

### Configuration
- Service configurations
- OdysseyGo directory structure
- Configuration files

## Expected Findings

Based on the cost spike investigation, you should see:

1. **High network activity starting July 10, 2025**
2. **Port 9651 traffic surge** (OdysseyGo consensus)
3. **Validator sync processes** consuming bandwidth
4. **140+ peer connections** to other validator nodes
5. **Network traffic patterns** matching the cost increase

## Troubleshooting

### Common Issues
- **Permission denied:** Run with `sudo`
- **No validator services found:** Check service naming convention
- **Port 9651 not in use:** Verify the application is running
- **Logs not found:** Check the OdysseyGo directory path

### Manual Commands
If the script fails, run these manually:

```bash
# Check services
sudo systemctl list-units --type=service | grep node-validator

# Check port usage
sudo lsof -i :9651
sudo netstat -tulpn | grep 9651

# Check logs
sudo journalctl -u node-validator-1 --since "2025-07-09 00:00:00" --until "2025-07-11 23:59:59"

# Check file logs
ls -la /home/ubuntu/OdysseyGo/odysseygo/db/
```

## File Structure

After running the script, you'll get:

```
validator_logs_YYYYMMDD_HHMMSS/
├── system_info.txt
├── validator_services.txt
├── processes.txt
├── network_usage.txt
├── service_logs/
│   ├── node-validator-1_cost_spike.log
│   ├── node-validator-1_recent.log
│   └── node-validator-1_today.log
├── file_logs/
├── config/
├── traffic_capture/
└── SUMMARY_REPORT.txt
```

## Next Steps

1. **Run on one server from each AWS account** (5 total)
2. **Compare logs across accounts** for patterns
3. **Look for July 10-11 activity** in service logs
4. **Analyze network traffic** patterns
5. **Correlate findings** with AWS cost data

## Support

The scripts include error handling and will create placeholder files if certain information can't be collected. Check the summary report for collection status.
