#!/bin/bash

# AWS Auto Scaling Web Server Testing Script
# This script tests the deployed infrastructure

echo "=========================================="
echo "AWS Auto Scaling Web Server Test Suite"
echo "=========================================="

# Configuration
ASG_NAME="your-auto-scaling-group-name"
REGION="us-east-1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ "$2" = "SUCCESS" ]; then
        echo -e "${GREEN}✓ $1${NC}"
    elif [ "$2" = "ERROR" ]; then
        echo -e "${RED}✗ $1${NC}"
    else
        echo -e "${YELLOW}ℹ $1${NC}"
    fi
}

# Test 1: Check Auto Scaling Group exists
print_status "Testing Auto Scaling Group existence..." "INFO"
ASG_EXISTS=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$ASG_NAME" --region "$REGION" --query 'AutoScalingGroups[0].AutoScalingGroupName' --output text 2>/dev/null)

if [ "$ASG_EXISTS" = "$ASG_NAME" ]; then
    print_status "Auto Scaling Group '$ASG_NAME' found" "SUCCESS"
else
    print_status "Auto Scaling Group '$ASG_NAME' not found" "ERROR"
    echo "Please update the ASG_NAME variable in this script"
    exit 1
fi

# Test 2: Get running instances
print_status "Retrieving running instances..." "INFO"
INSTANCES=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$ASG_NAME" --region "$REGION" --query 'AutoScalingGroups[0].Instances[?LifecycleState==`InService`].InstanceId' --output text)

if [ -z "$INSTANCES" ]; then
    print_status "No running instances found" "ERROR"
    exit 1
fi

INSTANCE_COUNT=$(echo $INSTANCES | wc -w)
print_status "Found $INSTANCE_COUNT running instances" "SUCCESS"

# Test 3: Check instance health
print_status "Checking instance health..." "INFO"
for instance in $INSTANCES; do
    HEALTH=$(aws ec2 describe-instance-status --instance-ids "$instance" --region "$REGION" --query 'InstanceStatuses[0].SystemStatus.Status' --output text 2>/dev/null)
    if [ "$HEALTH" = "ok" ]; then
        print_status "Instance $instance is healthy" "SUCCESS"
    else
        print_status "Instance $instance health check failed" "ERROR"
    fi
done

# Test 4: Test web server response
print_status "Testing web server responses..." "INFO"
for instance in $INSTANCES; do
    PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$instance" --region "$REGION" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    
    if [ "$PUBLIC_IP" != "None" ] && [ ! -z "$PUBLIC_IP" ]; then
        print_status "Testing HTTP response from $PUBLIC_IP..." "INFO"
        
        # Test HTTP connectivity
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://$PUBLIC_IP" --connect-timeout 10)
        
        if [ "$HTTP_STATUS" = "200" ]; then
            print_status "HTTP response from $PUBLIC_IP: OK ($HTTP_STATUS)" "SUCCESS"
            
            # Get hostname from response
            HOSTNAME=$(curl -s "http://$PUBLIC_IP" --connect-timeout 10 | grep -o 'ip-[0-9-]*' | head -1)
            if [ ! -z "$HOSTNAME" ]; then
                print_status "Server hostname: $HOSTNAME" "SUCCESS"
            fi
        else
            print_status "HTTP response from $PUBLIC_IP: FAILED ($HTTP_STATUS)" "ERROR"
        fi
    else
        print_status "Instance $instance has no public IP" "ERROR"
    fi
    
    echo "---"
done

# Test 5: Auto Scaling configuration
print_status "Checking Auto Scaling configuration..." "INFO"
ASG_CONFIG=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$ASG_NAME" --region "$REGION" --query 'AutoScalingGroups[0].[MinSize,MaxSize,DesiredCapacity]' --output text)

MIN_SIZE=$(echo $ASG_CONFIG | cut -d' ' -f1)
MAX_SIZE=$(echo $ASG_CONFIG | cut -d' ' -f2)
DESIRED=$(echo $ASG_CONFIG | cut -d' ' -f3)

print_status "Auto Scaling Group Configuration:" "INFO"
print_status "  Min Size: $MIN_SIZE" "INFO"
print_status "  Max Size: $MAX_SIZE" "INFO"
print_status "  Desired Capacity: $DESIRED" "INFO"
print_status "  Current Instances: $INSTANCE_COUNT" "INFO"

if [ "$INSTANCE_COUNT" -eq "$DESIRED" ]; then
    print_status "Instance count matches desired capacity" "SUCCESS"
else
    print_status "Instance count ($INSTANCE_COUNT) does not match desired capacity ($DESIRED)" "ERROR"
fi

# Test 6: Security Group configuration
print_status "Checking Security Group configuration..." "INFO"
SECURITY_GROUPS=$(aws autoscaling describe-launch-configurations --region "$REGION" --query 'LaunchConfigurations[0].SecurityGroups' --output text 2>/dev/null)

if [ -z "$SECURITY_GROUPS" ]; then
    # Try launch template instead
    LAUNCH_TEMPLATE=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$ASG_NAME" --region "$REGION" --query 'AutoScalingGroups[0].LaunchTemplate.LaunchTemplateId' --output text)
    if [ "$LAUNCH_TEMPLATE" != "None" ]; then
        print_status "Using Launch Template: $LAUNCH_TEMPLATE" "SUCCESS"
    fi
fi

# Test 7: Load test simulation (optional)
print_status "Would you like to run a load test? (y/n)" "INFO"
read -r LOAD_TEST

if [ "$LOAD_TEST" = "y" ] || [ "$LOAD_TEST" = "Y" ]; then
    print_status "Running load test simulation..." "INFO"
    
    for instance in $INSTANCES; do
        PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$instance" --region "$REGION" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        
        if [ "$PUBLIC_IP" != "None" ] && [ ! -z "$PUBLIC_IP" ]; then
            print_status "Load testing $PUBLIC_IP..." "INFO"
            
            # Simple load test with curl
            for i in {1..10}; do
                curl -s "http://$PUBLIC_IP" > /dev/null
                echo -n "."
            done
            echo ""
            print_status "Load test completed for $PUBLIC_IP" "SUCCESS"
        fi
    done
fi

echo ""
print_status "Test suite completed!" "SUCCESS"
echo "=========================================="
echo "Summary:"
echo "- Auto Scaling Group: $ASG_NAME"
echo "- Running Instances: $INSTANCE_COUNT"
echo "- Region: $REGION"
echo "=========================================="
