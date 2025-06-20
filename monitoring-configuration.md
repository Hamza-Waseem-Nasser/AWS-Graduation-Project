# CloudWatch Monitoring Configuration for AWS Auto Scaling Web Server

## Overview
This document outlines the monitoring and alerting strategy for the AWS Auto Scaling Web Server project.

## CloudWatch Metrics

### EC2 Instance Metrics
- **CPUUtilization**: Monitor CPU usage across all instances
- **NetworkIn/NetworkOut**: Track network traffic
- **StatusCheckFailed**: Monitor instance health
- **DiskReadOps/DiskWriteOps**: Monitor disk I/O

### Auto Scaling Group Metrics
- **GroupMinSize**: Minimum capacity setting
- **GroupMaxSize**: Maximum capacity setting
- **GroupDesiredCapacity**: Desired capacity setting
- **GroupInServiceInstances**: Number of healthy instances
- **GroupTotalInstances**: Total number of instances

### Application Load Balancer Metrics (if used)
- **RequestCount**: Number of requests
- **TargetResponseTime**: Response time from targets
- **HealthyHostCount**: Number of healthy targets
- **UnHealthyHostCount**: Number of unhealthy targets

## CloudWatch Alarms

### High CPU Utilization Alarm
```json
{
  "AlarmName": "WebServer-HighCPU",
  "AlarmDescription": "Alarm when CPU exceeds 70%",
  "MetricName": "CPUUtilization",
  "Namespace": "AWS/EC2",
  "Statistic": "Average",
  "Period": 300,
  "EvaluationPeriods": 2,
  "Threshold": 70,
  "ComparisonOperator": "GreaterThanThreshold",
  "Dimensions": [
    {
      "Name": "AutoScalingGroupName",
      "Value": "WebServer-ASG"
    }
  ]
}
```

### Low CPU Utilization Alarm
```json
{
  "AlarmName": "WebServer-LowCPU",
  "AlarmDescription": "Alarm when CPU is below 30%",
  "MetricName": "CPUUtilization",
  "Namespace": "AWS/EC2",
  "Statistic": "Average",
  "Period": 300,
  "EvaluationPeriods": 5,
  "Threshold": 30,
  "ComparisonOperator": "LessThanThreshold",
  "Dimensions": [
    {
      "Name": "AutoScalingGroupName",
      "Value": "WebServer-ASG"
    }
  ]
}
```

### Instance Status Check Alarm
```json
{
  "AlarmName": "WebServer-StatusCheckFailed",
  "AlarmDescription": "Alarm when instance status check fails",
  "MetricName": "StatusCheckFailed",
  "Namespace": "AWS/EC2",
  "Statistic": "Maximum",
  "Period": 60,
  "EvaluationPeriods": 2,
  "Threshold": 0,
  "ComparisonOperator": "GreaterThanThreshold"
}
```

## Scaling Policies

### Scale Out Policy
- **Trigger**: CPU Utilization > 70% for 2 consecutive periods (5 minutes each)
- **Action**: Add 1 instance
- **Cooldown**: 300 seconds

### Scale In Policy
- **Trigger**: CPU Utilization < 30% for 5 consecutive periods (5 minutes each)
- **Action**: Remove 1 instance
- **Cooldown**: 300 seconds

## CloudWatch Dashboard Configuration

```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "WebServer-ASG"],
          ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "WebServer-ALB"],
          ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", "WebServer-ASG"],
          ["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", "WebServer-ASG"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "Web Server Metrics"
      }
    }
  ]
}
```

## Log Groups

### Apache Access Logs
- **Log Group**: `/aws/ec2/apache/access`
- **Retention**: 30 days
- **Insights Queries**:
  ```
  fields @timestamp, @message
  | filter @message like /GET/
  | stats count() by bin(5m)
  ```

### Apache Error Logs
- **Log Group**: `/aws/ec2/apache/error`
- **Retention**: 30 days
- **Insights Queries**:
  ```
  fields @timestamp, @message
  | filter @message like /error/
  | sort @timestamp desc
  ```

### CloudWatch Agent Configuration
```json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "/aws/ec2/apache/access",
            "log_stream_name": "{instance_id}/access.log"
          },
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "/aws/ec2/apache/error",
            "log_stream_name": "{instance_id}/error.log"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "WebServer/Custom",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
```

## SNS Notifications

### Topic Configuration
- **Topic Name**: `WebServer-Alerts`
- **Protocol**: Email
- **Endpoint**: Your email address

### Alarm Actions
All CloudWatch alarms should be configured to publish to the SNS topic for immediate notification of issues.

## Cost Monitoring

### Budget Alert
- **Budget Name**: WebServer-Monthly-Budget
- **Amount**: $10 USD
- **Alert Threshold**: 80% of budget
- **Notification**: Email when threshold exceeded

### Cost Allocation Tags
- **Project**: AWS-Auto-Scaling-Web-Server
- **Environment**: Production/Development
- **Owner**: Your Name

## Best Practices

1. **Regular Review**: Review metrics weekly to optimize thresholds
2. **Testing**: Test alarm notifications regularly
3. **Documentation**: Keep monitoring configuration updated
4. **Automation**: Use Infrastructure as Code for monitoring setup
5. **Security**: Ensure CloudWatch logs don't contain sensitive data
