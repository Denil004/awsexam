#!/bin/bash

# Deployment script for Ubuntu on AWS EC2
# Django + Nginx + Gunicorn

echo "Updating system packages..."
sudo apt update -y

echo "Installing Python 3, venv, pip, Git, Nginx, and system dependencies..."
sudo apt install python3 python3-venv python3-pip python3-dev pkg-config default-libmysqlclient-dev git nginx -y

echo "Creating application directory..."
mkdir -p /home/ubuntu/app
# Note: If you cloned the repository via Git, you can copy its contents here or run from the pulled directory.

echo "Setting up Python virtual environment..."
cd /home/ubuntu/app
python3 -m venv venv
source venv/bin/activate

echo "Installing requirements..."
pip install -r requirements.txt

echo "Collecting static files (make sure your .env has DB details soon)..."
python manage.py collectstatic --noinput || true

echo "Setting up Gunicorn systemd service..."
sudo bash -c 'cat > /etc/systemd/system/gunicorn.service <<EOF
[Unit]
Description=gunicorn daemon
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/app
ExecStart=/home/ubuntu/app/venv/bin/gunicorn --access-logfile - --workers 3 --bind unix:/home/ubuntu/app/app.sock core.wsgi:application

[Install]
WantedBy=multi-user.target
EOF'

echo "Setting up Nginx configuration..."
sudo bash -c 'cat > /etc/nginx/sites-available/django_app <<EOF
server {
    listen 80;
    server_name _;

    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        root /home/ubuntu/app;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/ubuntu/app/app.sock;
    }
}
EOF'

echo "Enabling Nginx site..."
sudo ln -sf /etc/nginx/sites-available/django_app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

echo "Restarting services..."
sudo systemctl daemon-reload
sudo systemctl start gunicorn
sudo systemctl enable gunicorn
sudo systemctl restart nginx
sudo systemctl enable nginx

echo -e "\n--- DEPLOYMENT SUCCESSFUL ---"
echo "Make sure to create your .env file with your RDS details in /home/ubuntu/app/.env"
echo "Once created, restart gunicorn with: sudo systemctl restart gunicorn"
echo "To create your database tables run:"
echo "cd /home/ubuntu/app"
echo "source venv/bin/activate"
echo "python manage.py migrate"
echo -e "\nNote: Ensure the EC2 security group allows traffic on port 80 (HTTP) from your IP, and the RDS security group allows port 3306 originating from this EC2 instance."
