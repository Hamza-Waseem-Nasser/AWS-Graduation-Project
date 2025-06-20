#!/bin/bash
# AWS EC2 Auto Scaling User Data Script
# This script automatically configures Apache web server on new instances

# Update the system packages
yum update -y

# Install Apache web server
yum install -y httpd

# Start Apache service
systemctl start httpd

# Enable Apache to start on boot
systemctl enable httpd

# Create a simple HTML page that displays the hostname
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html

# Add additional server information (optional)
echo "<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
echo "<p>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>" >> /var/www/html/index.html
echo "<p>Instance Type: $(curl -s http://169.254.169.254/latest/meta-data/instance-type)</p>" >> /var/www/html/index.html
echo "<p>Server Time: $(date)</p>" >> /var/www/html/index.html

# Set proper permissions
chmod 644 /var/www/html/index.html

# Ensure Apache is running
systemctl status httpd
