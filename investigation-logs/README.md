# 📊 Investigation Logs

This directory contains **actual log files** collected during the AWS cost investigation from the 5 bootstrap validator servers.

## 📁 Log Directory Structure

### Bootstrap Validator Logs
- **`logs_aws_core_1/`** - Logs from Bootstrap Validator 1 (IP: 172.31.29.29)
- **`logs_aws_core_2/`** - Logs from Bootstrap Validator 2 (IP: 172.31.25.213)  
- **`logs_aws_core_3/`** - Logs from Bootstrap Validator 3 (IP: 172.31.25.79)
- **`logs_aws_core_4/`** - Logs from Bootstrap Validator 4 (IP: 172.31.17.110)
- **`logs_aws_core_5/`** - Logs from Bootstrap Validator 5 (IP: 172.31.24.48)

### System Information
- **`validator_logs_20250819_204745/`** - System information and validator details

## 🔍 What's in Each Log Directory

### Core Log Files (per validator)
Each `logs_aws_core_X/` directory contains:

- **`consensus_activity_*.log`** - Consensus participation and voting logs
- **`live_traffic_9651_*.log`** - Real-time port 9651 traffic monitoring
- **`network_activity_*.log`** - Network connection and routing logs
- **`port_9651_connections_*.log`** - Active connections to port 9651
- **`port_9651_usage_*.log`** - Port 9651 bandwidth usage statistics
- **`processes_*.log`** - Running processes and resource usage
- **`validator_X_cost_spike.log`** - Specific cost spike investigation logs

## 📊 Log Data Types

### Network Monitoring Data
- **Connection counts** to port 9651
- **Data transfer rates** (inbound/outbound)
- **Active IP addresses** connecting to validators
- **Network interface statistics** (RX/TX bytes)

### Consensus Activity
- **Validator participation** in consensus rounds
- **Block validation** and voting records
- **Network synchronization** status
- **Performance metrics** and timing

### System Performance
- **CPU and memory usage** during investigation
- **Process monitoring** for validator services
- **Resource utilization** patterns
- **System health** indicators

## 🔍 Investigation Timeline

### Log Collection Period
- **Start Date:** August 19, 2025
- **Investigation Period:** August 19-22, 2025
- **Collection Frequency:** Every 5 minutes during peak hours
- **Total Data:** ~7.7TB incoming, 6.8TB outgoing per validator

### Key Investigation Moments
- **Initial cost spike detection** - August 19
- **Connection analysis** - August 20-21
- **Deep investigation** - August 21-22
- **Final validation** - August 22

## 📈 How to Use These Logs

### For Ongoing Monitoring
1. **Compare current logs** with these baseline logs
2. **Track connection patterns** over time
3. **Monitor for anomalies** or changes
4. **Validate optimization** results

### For Analysis
1. **Import into log analysis tools** (ELK stack, Splunk)
2. **Use for trend analysis** and pattern recognition
3. **Correlate with cost data** from `costs/` directory
4. **Create dashboards** for ongoing monitoring

### For Troubleshooting
1. **Reference these logs** when investigating issues
2. **Compare current behavior** with baseline
3. **Identify changes** that might cause problems
4. **Validate fixes** by comparing before/after logs

## 🚨 Important Notes

### Data Sensitivity
- **These are production logs** - handle with appropriate security
- **Contains network topology information** - don't share publicly
- **Use for internal investigation** and monitoring only

### Log Formats
- **Text-based logs** - easily readable with standard tools
- **Structured data** - can be parsed for analysis
- **Timestamped entries** - for chronological analysis
- **Multiple log levels** - INFO, WARNING, ERROR

## 🔧 Log Analysis Tools

### Recommended Tools
- **`grep` and `awk`** - Basic text searching and filtering
- **ELK Stack (Elasticsearch, Logstash, Kibana)** - Advanced log analysis
- **Splunk** - Enterprise log management
- **Python scripts** - Custom log parsing and analysis
- **Excel/Google Sheets** - Basic log data analysis

### Example Commands
```bash
# Search for connection patterns
grep "ESTAB" logs_aws_core_1/port_9651_connections_*.log

# Count connections over time
awk '/ESTAB/ {print $1, $2}' logs_aws_core_1/port_9651_connections_*.log | sort | uniq -c

# Extract network statistics
grep "RX\|TX" logs_aws_core_1/network_activity_*.log
```

## 📋 Investigation Checklist

### Data Collection
- [x] **Collect logs from all 5 bootstrap validators**
- [x] **Monitor port 9651 activity** for 48+ hours
- [x] **Record network statistics** every 5 minutes
- [x] **Document connection patterns** and counts

### Analysis Complete
- [x] **Identify connection sources** (89 legitimate validators)
- [x] **Verify network health** (no security issues)
- [x] **Document cost drivers** (normal network operation)
- [x] **Recommend optimization strategies** (20-30% cost reduction)

## 🔗 Related Resources

- **[📖 Main Investigation Report](../docs/AWS_COST_INVESTIGATION_REPORT.md)**
- **[💰 Cost Data](../costs/)**
- **[🔧 Investigation Scripts](../scripts/)**
- **[📊 Monitoring Guide](../docs/PORT_9651_MONITORING_GUIDE.md)**

---

**Log Type:** Production validator logs  
**Collection Period:** August 19-22, 2025  
**Validators:** 5 bootstrap nodes  
**Purpose:** Cost investigation baseline and ongoing monitoring
