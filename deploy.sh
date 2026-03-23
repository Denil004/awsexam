#!/bin/bash

# Deployment script for Amazon Linux 2 / Amazon Linux 2023 
# Assuming you ssh'ed into the box as ec2-user

echo "Updating system packages..."
sudo yum update -y

echo "Installing Python 3 and Git..."
sudo yum install python3 git -y

echo "Creating application directory..."
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

# Option: Here you could clone from git instead:
# git clone <your-repo> .

echo "Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

echo "Installing requirements..."
pip install -r requirements.txt

echo "\n--- DEPLOYMENT SUCCESSFUL ---"
echo "Make sure to create your .env file in /home/ec2-user/app/.env with your RDS details."
echo "To run the app:"
echo "source /home/ec2-user/app/venv/bin/activate"
echo "python app.py"
echo "\nNote: Ensure the EC2 security group allows traffic on port 8000 from your IP/ALB, and the RDS security group allows port 3306 originating from the EC2 instance's security group."
