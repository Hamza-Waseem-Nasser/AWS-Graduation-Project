# AWS Auto Scaling Deployment Guide

This guide provides step-by-step instructions for deploying the AWS EC2 Auto Scaling web server project.

## Prerequisites

- AWS Account with appropriate IAM permissions
- Access to AWS Management Console
- Basic understanding of EC2, VPC, and Security Groups

## Step 1: Create Security Group

1. Navigate to EC2 → Security Groups
2. Click "Create Security Group"
3. **Name**: `web-server-sg`
4. **Description**: `Security group for auto scaling web servers`
5. **VPC**: Select your default VPC
6. **Inbound Rules**:
   - Type: HTTP, Port: 80, Source: 0.0.0.0/0
   - Type: SSH, Port: 22, Source: Your IP (for troubleshooting)
7. Click "Create Security Group"

## Step 2: Create Launch Template

1. Navigate to EC2 → Launch Templates
2. Click "Create Launch Template"
3. **Template Name**: `web-server-template`
4. **Template Description**: `Launch template for auto scaling web servers`
5. **Amazon Machine Image (AMI)**: Amazon Linux 2 AMI (HVM)
6. **Instance Type**: t2.micro (or t3.micro)
7. **Key Pair**: Select existing or create new (optional)
8. **Security Groups**: Select `web-server-sg` created above
9. **Advanced Details** → **User Data**:
   ```bash
   #!/bin/bash
   yum update -y
   yum install -y httpd
   systemctl start httpd
   systemctl enable httpd
   echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
   echo "<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
   echo "<p>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>" >> /var/www/html/index.html
   echo "<p>Server Time: $(date)</p>" >> /var/www/html/index.html
   ```
10. Click "Create Launch Template"

## Step 3: Create Auto Scaling Group

1. Navigate to EC2 → Auto Scaling Groups
2. Click "Create Auto Scaling Group"
3. **Name**: `web-server-asg`
4. **Launch Template**: Select `web-server-template`
5. **Version**: Latest
6. Click "Next"
7. **VPC**: Select your default VPC
8. **Availability Zones**: Select 2 or more AZs
9. **Subnets**: Select public subnets in chosen AZs
10. Click "Next"
11. **Load Balancing**: None (for this basic setup)
12. **Health Checks**: EC2
13. **Health Check Grace Period**: 300 seconds
14. Click "Next"
15. **Group Size**:
    - Desired Capacity: 2
    - Minimum Capacity: 1
    - Maximum Capacity: 5
16. **Scaling Policies**: None (for manual demo)
17. Click "Next" through remaining screens
18. Click "Create Auto Scaling Group"

## Step 4: Test the Deployment

1. Wait 3-5 minutes for instances to launch
2. Navigate to EC2 → Instances
3. Find instances with names starting with your ASG name
4. Copy the public IP address of each instance
5. Open browser and visit `http://[PUBLIC-IP]`
6. You should see "Hello World from ip-xxx-xxx-xxx-xxx"

## Step 5: Test Auto Scaling Features

### Test Self-Healing
1. Select one running instance
2. Click "Instance State" → "Terminate"
3. Wait 2-3 minutes
4. Verify that ASG launches a replacement instance

### Test Manual Scaling
1. Navigate to Auto Scaling Groups
2. Select your ASG
3. Click "Edit" → "Group Details"
4. Change "Desired Capacity" to 3
5. Wait for new instance to launch
6. Test the new instance's public IP

## Optional: Add Application Load Balancer

1. Navigate to EC2 → Load Balancers
2. Click "Create Load Balancer"
3. Choose "Application Load Balancer"
4. **Name**: `web-server-alb`
5. **Scheme**: Internet-facing
6. **IP Address Type**: IPv4
7. **VPC**: Your default VPC
8. **Mappings**: Select same AZs as ASG
9. **Security Group**: Create new or use existing (allow HTTP)
10. **Target Group**: Create new
    - **Name**: `web-server-targets`
    - **Protocol**: HTTP
    - **Port**: 80
    - **Health Check Path**: /
11. Complete ALB creation
12. Edit ASG to attach the target group

## Troubleshooting

### Instance not launching
- Check IAM permissions
- Verify security group settings
- Check VPC/subnet configuration

### Web page not loading
- Verify security group allows HTTP (port 80)
- Check instance public IP assignment
- SSH to instance and check httpd status: `sudo systemctl status httpd`

### Auto Scaling not working
- Check ASG health check settings
- Verify launch template configuration
- Check CloudWatch logs for errors

## Cleanup

To avoid charges, delete resources in this order:
1. Auto Scaling Group (set desired capacity to 0 first)
2. Launch Template
3. Load Balancer (if created)
4. Target Group (if created)
5. Security Group

## Cost Considerations

- t2.micro instances are free tier eligible
- Charges apply for data transfer and additional instances
- Consider scheduled scaling for predictable workloads
- Monitor usage with AWS Cost Explorer

## Next Steps

- Add CloudWatch monitoring and alarms
- Implement scaling policies based on CPU utilization
- Add SSL/TLS certificate for HTTPS
- Integrate with AWS Systems Manager for patching
- Implement blue-green deployment strategies
