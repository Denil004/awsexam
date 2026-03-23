#!/bin/bash

# Deployment script for Ubuntu on AWS EC2
# Assuming you ssh'ed into the box as the ubuntu user

echo "Updating system packages..."
sudo apt update -y

echo "Installing Python 3, venv, pip, and Git..."
sudo apt install python3 python3-venv python3-pip git -y

echo "Creating application directory..."
mkdir -p /home/ubuntu/app
# Note: If you cloned the repository via Git, you can copy its contents here or run from the pulled directory.

echo "Setting up Python virtual environment..."
cd /home/ubuntu/app
python3 -m venv venv
source venv/bin/activate

echo "Installing requirements..."
pip install -r requirements.txt

echo -e "\n--- DEPLOYMENT SUCCESSFUL ---"
echo "Make sure to create your .env file with your RDS details in /home/ubuntu/app/.env"
echo "To run the app:"
echo "cd /home/ubuntu/app"
echo "source venv/bin/activate"
echo "python app.py"
echo -e "\nNote: Ensure the EC2 security group allows traffic on port 8000 from your IP, and the RDS security group allows port 3306 originating from this EC2 instance."
