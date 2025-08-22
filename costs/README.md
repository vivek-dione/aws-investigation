# 💰 AWS Cost Data

This directory contains actual AWS Cost Explorer data exported from the 5 AWS accounts hosting Odyssey Network validators.

## 📊 Cost Data Files

### Current Cost Data
- **`costs (1).csv`** - AWS Account 1 cost data
- **`costs (2).csv`** - AWS Account 2 cost data  
- **`costs (3).csv`** - AWS Account 3 cost data
- **`costs (4).csv`** - AWS Account 4 cost data

### Data Description
These CSV files contain **real cost data** exported from AWS Cost Explorer, showing:
- **Daily/monthly costs** for each validator account
- **Data transfer costs** (inbound/outbound)
- **EC2 instance costs** for validator servers
- **Storage and other AWS service costs**
- **Cost breakdown by service** and region

## 🔍 How to Use This Data

### Cost Analysis
1. **Import into Excel/Google Sheets** for analysis
2. **Use for cost trend analysis** over time
3. **Compare costs across accounts** to identify patterns
4. **Track cost optimization** progress after implementing changes

### Data Fields
Typical columns include:
- **Date** - Cost date
- **Account** - AWS account identifier
- **Service** - AWS service (EC2, Data Transfer, etc.)
- **Region** - AWS region
- **Usage Type** - Specific usage category
- **Cost** - Amount in USD
- **Usage Amount** - Resource usage quantity

## 📈 Cost Optimization Tracking

### Before Optimization
- **Baseline costs** from these CSV files
- **Data transfer costs** that prompted investigation
- **Cost patterns** across different accounts

### After Optimization
- **Export new cost data** to compare
- **Track cost reduction** percentages
- **Monitor ongoing costs** to ensure sustainability

## 🚨 Important Notes

### Data Sensitivity
- **These are real cost files** - handle with appropriate security
- **Contains actual AWS account information** - don't share publicly
- **Use for internal analysis** and cost optimization planning

### Data Freshness
- **Export dates** should be noted for each file
- **Regular updates** recommended for ongoing monitoring
- **Compare with current costs** before making decisions

## 🔧 Cost Analysis Tools

### Recommended Tools
- **Excel/Google Sheets** - Basic analysis and charts
- **Python pandas** - Advanced data analysis
- **AWS Cost Explorer** - Real-time cost monitoring
- **Custom dashboards** - For ongoing cost tracking

### Analysis Examples
```python
# Example Python analysis
import pandas as pd

# Load cost data
costs = pd.read_csv('costs (1).csv')

# Analyze data transfer costs
data_transfer = costs[costs['Service'] == 'Data Transfer']
print(f"Total data transfer cost: ${data_transfer['Cost'].sum():.2f}")
```

## 📋 Cost Optimization Checklist

### Immediate Actions
- [ ] **Review current costs** from these CSV files
- [ ] **Identify highest cost drivers** (likely data transfer)
- [ ] **Set cost reduction targets** (20-30% goal)
- [ ] **Implement optimization strategies** from main report

### Ongoing Monitoring
- [ ] **Export new cost data** weekly/monthly
- [ ] **Track cost reduction** progress
- [ ] **Monitor for cost spikes** or anomalies
- [ ] **Adjust optimization strategies** based on results

## 🔗 Related Resources

- **[📖 Main Investigation Report](../docs/AWS_COST_INVESTIGATION_REPORT.md)**
- **[💰 Cost Optimization Strategies](../docs/AWS_COST_INVESTIGATION_REPORT.md#-cost-optimization-strategies)**
- **[📊 Monitoring Scripts](../scripts/)**

---

**Data Type:** AWS Cost Explorer Exports  
**Accounts:** 5 validator AWS accounts  
**Update Frequency:** As needed for analysis  
**Purpose:** Cost analysis and optimization tracking
