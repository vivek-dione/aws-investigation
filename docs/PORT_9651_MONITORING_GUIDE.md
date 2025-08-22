# Port 9651 Traffic Monitoring Guide

## Overview
Monitor outbound traffic on port 9651 to measure data consumption changes when starting an archive node.

## Monitoring Options (Choose One)

### Option 1: 5-Minute Periods (Recommended)
**File**: `simple_port_9651_monitor.sh`
- **What it shows**: Data consumed every 5 minutes
- **Easy to read**: "5.2 MB consumed in 5 minutes"
- **Good for**: Testing archive node impact

### Option 2: Hourly Periods (Best for Long-term)
**File**: `hourly_port_9651_monitor.sh`
- **What it shows**: Data consumed every hour
- **Easy to read**: "156 MB consumed in 1 hour"
- **Good for**: Long-term monitoring and cost analysis

### Option 3: Advanced Real-time (For Developers)
**File**: `monitor_port_9651_traffic.sh`
- **What it shows**: Data every second with detailed metrics
- **More complex**: Real-time rates and process details
- **Good for**: Debugging and detailed analysis

## Quick Start (5-Minute Monitoring)

### 1. Upload Script to Validator Server
```bash
scp simple_port_9651_monitor.sh ubuntu@YOUR_VALIDATOR_IP:/home/ubuntu/
```

### 2. Start Monitoring (Baseline)
```bash
ssh ubuntu@YOUR_VALIDATOR_IP
chmod +x simple_port_9651_monitor.sh
./simple_port_9651_monitor.sh
```

### 3. What You'll See
```
Period Start | Period End | Data Consumed (5min) | Avg Rate | Connections
------------------------------------------------------------------------
2025-01-20 10:00:00 | 2025-01-20 10:05:00 | 2.1 MB (2150 KB) | 430 KB/min | 85 connections
2025-01-20 10:05:00 | 2025-01-20 10:10:00 | 1.8 MB (1843 KB) | 369 KB/min | 87 connections
```

### 4. Start Archive Node (Test)
```bash
# In another terminal, start your archive node on another server
# Watch for increased data consumption in the next 5-minute period
```

### 5. Expected Results
**Before Archive Node**: 1-3 MB per 5 minutes
**After Archive Node**: 5-15+ MB per 5 minutes

## Quick Start (Hourly Monitoring)

### 1. Upload Script
```bash
scp hourly_port_9651_monitor.sh ubuntu@YOUR_VALIDATOR_IP:/home/ubuntu/
```

### 2. Start Monitoring
```bash
chmod +x hourly_port_9651_monitor.sh
./hourly_port_9651_monitor.sh
```

### 3. What You'll See
```
Hour Start | Hour End | Data Consumed | Avg Rate | Connections (min-max)
------------------------------------------------------------------------
2025-01-20 10:00:00 | 2025-01-20 11:00:00 | 156 MB (0.15 GB) | 2667 KB/min | 82-89
2025-01-20 11:00:00 | 2025-01-20 12:00:00 | 234 MB (0.23 GB) | 4000 KB/min | 85-95
```

## What the Scripts Monitor

### Metrics Tracked:
- **Data Consumed**: Total outbound data over the period
- **Average Rate**: KB per minute over the period
- **Connections**: Min/max connections on port 9651
- **Period Summary**: Clear start/end times

### Output Files:
- **Real-time display**: Shows period summaries
- **CSV log file**: Saves all data for analysis

## Understanding the Results

### Normal Operation (Baseline):
- **5-minute periods**: 1-3 MB consumed
- **Hourly periods**: 50-200 MB consumed
- **Connection range**: 80-90 connections
- **Stable patterns**: Consistent consumption

### With Archive Node:
- **5-minute periods**: 5-15+ MB consumed
- **Hourly periods**: 200-500+ MB consumed
- **Connection range**: 90-120+ connections
- **Data spikes**: During sync operations

## Data Analysis

### Download Results:
```bash
# Download the log file to your local machine
scp ubuntu@YOUR_VALIDATOR_IP:/home/ubuntu/port_9651_*.log ./
```

### Analyze in Excel/Google Sheets:
- Import the CSV file
- Create charts showing data consumption over time
- Compare baseline vs. archive node periods
- Calculate cost impact: 1 GB = $0.09 AWS charge

## Troubleshooting

### If Script Fails:
```bash
# Check if ens5 interface exists
ls /sys/class/net/

# Find correct interface name
ip route | grep default

# Edit script and change "ens5" to your interface name
```

### If No Data:
```bash
# Check if odysseygo is running
pgrep odysseygo

# Check port 9651 connections
ss -t -n | grep ":9651"
```

## Cost Impact Calculation

### Example Calculation:
- **Baseline**: 150 MB/hour = 3.6 GB/day = $0.32/day
- **With Archive Node**: 400 MB/hour = 9.6 GB/day = $0.86/day
- **Cost Increase**: $0.54/day = $16.20/month

### Scale to 75 Validators:
- **Total cost increase**: $0.54 × 75 = $40.50/day
- **Monthly impact**: $40.50 × 30 = $1,215/month

## Recommendation

**Start with the 5-minute monitoring script** (`simple_port_9651_monitor.sh`) because:
1. **Easy to understand**: Clear 5-minute summaries
2. **Quick results**: See changes within 5 minutes
3. **Good for testing**: Perfect for archive node impact testing
4. **Simple output**: "2.1 MB consumed in 5 minutes" is easy to interpret
