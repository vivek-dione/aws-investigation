# 🔧 Scripts Directory

This directory contains all the investigation, monitoring, and utility scripts used during the AWS cost investigation.

## 📋 Script Categories

### 🔍 Investigation Scripts
These scripts were used during the step-by-step investigation process:

- **`step-by-step-analysis.sh`** - Step 1: Clean connection analysis and overview
- **`investigation-step2.sh`** - Step 2: Deep dive into connection details
- **`investigation-step3.sh`** - Step 3: Extract real IP addresses from connections
- **`investigation-step4.sh`** - Step 4: Final validation and recommendations

### 📊 Monitoring Scripts
Scripts for ongoing network monitoring and traffic analysis:

- **`simple_port_9651_monitor.sh`** - Basic real-time port 9651 traffic monitoring
- **`hourly_port_9651_monitor.sh`** - Hourly traffic monitoring with detailed logging
- **`monitor_port_9651_traffic.sh`** - Comprehensive traffic analysis and reporting

### 🛠️ Utility Scripts
Helper scripts for log collection and verification:

- **`collect_logs_from_server.sh`** - Collect logs from validator servers
- **`collect_validator_logs.sh`** - Collect specific validator logs
- **`verify_port_9651.sh`** - Verify port 9651 is accessible and working

## 🚀 Usage Instructions

### Prerequisites
- **Linux/Unix system** (tested on Ubuntu)
- **Bash shell** (most scripts use bash-specific features)
- **Root/sudo access** (for some monitoring commands)
- **Network tools** (`ss`, `tcpdump`, etc.)

### Running Scripts
```bash
# Make scripts executable (if not already)
chmod +x *.sh

# Run investigation scripts
./step-by-step-analysis.sh
./investigation-step2.sh
./investigation-step3.sh
./investigation-step4.sh

# Run monitoring scripts
./simple_port_9651_monitor.sh
./hourly_port_9651_monitor.sh
./monitor_port_9651_traffic.sh

# Run utility scripts
./collect_logs_from_server.sh
./collect_validator_logs.sh
./verify_port_9651.sh
```

## 📊 Output Examples

### Investigation Scripts Output
```
=== STEP 1: CLEAN CONNECTION ANALYSIS ===
Time: Fri Aug 22 04:28:36 UTC 2025

1. TOTAL CONNECTIONS TO PORT 9651:
   Total: 89 connections

2. BREAKDOWN BY CONNECTION TYPE:
   Legitimate IP connections:
     89 unique source IPs
   Malformed connections: 0
```

### Monitoring Scripts Output
```
=======================================
  PORT 9651 OUTBOUND TRAFFIC MONITOR
=======================================
Period Start | Period End | Data Consumed (5min) | Avg Rate | Connections
------------------------------------------------------------------------
2025-08-22 04:25:00 | 2025-08-22 04:30:00 | 500 MB (512000 KB) | 102400 KB/min | 89 connections
```

## 🔧 Customization

### Modifying Scripts
- **Update IP addresses** in monitoring scripts for your network
- **Adjust time intervals** in monitoring scripts as needed
- **Modify output formats** to match your logging requirements
- **Add email alerts** for critical thresholds

### Configuration Files
- **Network interface names** (default: `ens5`)
- **Port numbers** (default: `9651`)
- **Monitoring intervals** (default: `5 minutes`)
- **Alert thresholds** (customizable)

## 📈 Performance Considerations

### Resource Usage
- **CPU:** Minimal impact (mostly I/O operations)
- **Memory:** Low memory usage
- **Network:** No additional network overhead
- **Disk:** Log file growth depends on monitoring frequency

### Scaling
- **Single server:** All scripts work on single validator
- **Multiple servers:** Can run monitoring scripts on each server
- **Centralized monitoring:** Aggregate logs from multiple servers

## 🛡️ Security Notes

### Permissions
- **Some scripts require sudo** for network monitoring
- **Log files should be protected** from unauthorized access
- **Scripts should run under appropriate user accounts**

### Network Access
- **Scripts only monitor** - they don't modify network settings
- **No external connections** made by monitoring scripts
- **All data stays local** to the server

## 🔗 Related Documentation

- **[📖 Main Investigation Report](../docs/AWS_COST_INVESTIGATION_REPORT.md)**
- **[📊 Monitoring Guide](../docs/PORT_9651_MONITORING_GUIDE.md)**
- **[📋 Usage Guide](../docs/USAGE_GUIDE.md)**

## 📞 Support

### Troubleshooting
- **Check script permissions** (`chmod +x script.sh`)
- **Verify network tools** are installed (`ss`, `tcpdump`)
- **Check log files** for error messages
- **Ensure sudo access** for privileged operations

### Getting Help
- **Review the main investigation report** for context
- **Check script comments** for usage details
- **Test scripts on non-production** systems first
- **Monitor resource usage** when running scripts

---

**Last Updated:** August 22, 2025  
**Script Count:** 12 scripts  
**Categories:** 3 (Investigation, Monitoring, Utility)
