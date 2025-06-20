# AWS EC2 Auto Scaling Web Server

This project demonstrates how to deploy a scalable Apache web server using EC2 Auto Scaling and a Bash User Data script on AWS.

## 🚀 Project Overview

- Automatically launch EC2 instances with Apache HTTP server
- Auto Scaling Group handles demand and health checks
- Simple website response with server hostname
- Infrastructure automation using User Data scripts

## 🛠️ Tech Stack

- **Amazon EC2** - Virtual servers in the cloud
- **Auto Scaling Group** - Automatic scaling based on demand
- **Launch Template** - Instance configuration template
- **Amazon Machine Image (AMI)** - Pre-configured server image
- **User Data Script (Bash)** - Automated setup script
- **Apache HTTP Server (`httpd`)** - Web server software
- **CloudFormation** - Infrastructure as Code
- **CloudWatch** - Monitoring and logging
- **Optional: Elastic Load Balancer** - Traffic distribution

## 📁 Project Files

- `user-data-script.sh` - EC2 instance setup automation
- `cloudformation-template.yaml` - Infrastructure as Code template
- `test-infrastructure.sh` - Automated testing script
- `monitoring-configuration.md` - CloudWatch monitoring setup
- `deployment-guide.md` - Step-by-step deployment instructions
- `architecture-overview.md` - Detailed architecture documentation

## 🧩 Architecture Diagram

![Architecture Diagram](./architecture-diagram.png)

*The architecture shows users accessing a web application through an Auto Scaling Group that automatically manages EC2 instances running Apache web servers.*

## 📜 User Data Script

The heart of this project is the automated setup script that runs on each new EC2 instance:

```bash
#!/bin/bash
# Update instance
yum update -y

# Install Apache web server
yum install -y httpd

# Start Apache
systemctl start httpd

# Enable Apache on boot
systemctl enable httpd

# Serve a Hello World page with hostname
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
```

## 📦 How It Works

1. **Auto Scaling Group** is triggered with a desired capacity
2. **Launch Template** provisions new EC2 instance with Amazon Linux 2
3. **User Data script** automatically installs and configures Apache
4. **Apache starts** on boot and serves a Hello World HTML page with hostname
5. **Health checks** ensure instances are running properly
6. **Auto scaling** adds/removes instances based on demand

## 🔧 Setup Instructions

### Prerequisites
- AWS Account with appropriate permissions
- Basic understanding of EC2 and Auto Scaling

### Deployment Steps

1. **Create Launch Template**
   - Use Amazon Linux 2 AMI
   - Instance type: `t2.micro` or `t3.micro`
   - Paste the `user-data-script.sh` content in User Data section
   - Configure security group (allow HTTP port 80)

2. **Create Auto Scaling Group**
   - Attach to the launch template
   - Set desired capacity: 2
   - Minimum capacity: 1
   - Maximum capacity: 5
   - Choose appropriate subnets

3. **Optional: Add Load Balancer**
   - Create Application Load Balancer
   - Attach Auto Scaling Group as target

4. **Test the Setup**
   - Visit instance public IP addresses
   - You should see: "Hello World from ip-xxx-xxx-xxx-xxx"

## 🧪 Testing Auto Scaling

- **Scale Out**: Manually increase desired capacity to see new instances launch
- **Self-Healing**: Terminate an instance to test automatic replacement
- **Load Testing**: Use tools like Apache Bench to trigger scaling events

## 📸 Project Features

- ✅ Automated instance provisioning
- ✅ Self-healing infrastructure
- ✅ Horizontal scaling capability
- ✅ Simple web server deployment
- ✅ Infrastructure as Code principles

## 📚 Learning Objectives

- Understand EC2 Auto Scaling concepts
- Learn Bash scripting for automation
- Implement infrastructure as code
- Practice AWS best practices for scalability

## 🎯 Future Enhancements

- ✅ CloudFormation template for Infrastructure as Code
- ✅ Automated testing scripts
- ✅ Comprehensive monitoring configuration
- Add SSL/TLS certificates with AWS Certificate Manager
- Implement blue-green deployment strategy
- Database integration with RDS
- Container-based deployment with ECS/EKS
- API Gateway integration for microservices
- AWS WAF for web application firewall
- Multi-region deployment for disaster recovery

## 🌐 Live Demo

This project includes a demo script for creating presentation videos. The infrastructure can be deployed and tested in any AWS account following the deployment guide.

## 🎯 Project Goals

This project was built to demonstrate my understanding of:
- AWS cloud infrastructure design and implementation
- Horizontal scaling concepts and best practices
- Infrastructure automation using scripts
- High availability and fault tolerance in cloud environments

## 📋 Implementation Details

This repository showcases my work on:
- ✅ Complete solution architecture design
- ✅ Infrastructure automation scripts
- ✅ Comprehensive documentation and deployment guides
- ✅ Visual architecture representation
- ✅ Production-ready configuration examples

## 🔮 Lessons Learned

Through this project, I gained hands-on experience with:
- AWS Auto Scaling Groups and Launch Templates
- Bash scripting for server automation
- Infrastructure as Code principles
- Cloud cost optimization strategies
- Security best practices for web applications

## 📞 About This Project

This AWS Auto Scaling project represents my practical application of cloud engineering concepts. The implementation follows industry best practices and demonstrates scalable, fault-tolerant infrastructure design.
