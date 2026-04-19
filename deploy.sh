#!/bin/bash
set -e

echo "======================================================"
echo "  AWS EC2 + RDS Complete Django Deployment Script   "
echo "======================================================"

# Dynamically pick up the current directory of the cloned repo
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Setting up application at: $APP_DIR"

if [ ! -f "$APP_DIR/.env" ]; then
    echo "--------------------------------------------------------"
    echo "⚠️  WARNING: .env file not found!"
    echo "Creating it from .env.example..."
    cp "$APP_DIR/.env.example" "$APP_DIR/.env"
    echo "--------------------------------------------------------"
    echo "ACTION REQUIRED: Please inject your RDS credentials before deploying!"
    echo "1. Edit the file by running: nano $APP_DIR/.env"
    echo "2. Once saved, re-run this script: ./deploy.sh"
    exit 1
fi

echo ">> Installing necessary system packages (Python, Nginx, MySQL libs)..."
sudo apt update -y
sudo apt install python3 python3-venv python3-pip python3-dev pkg-config default-libmysqlclient-dev git nginx curl -y

echo ">> Securing $USER directory permissions for Nginx access..."
# Grant Nginx (www-data) traversal rights into the home & app directories
sudo chmod 755 $HOME
sudo chmod 755 $APP_DIR
# Add www-data to the current user's group so it can read the Unix socket
sudo usermod -a -G $USER www-data

echo ">> Setting up Python Virtual Environment..."
cd "$APP_DIR"
python3 -m venv venv
source venv/bin/activate

echo ">> Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo ">> Synchronizing Database (Makemigrations & Migrate)..."
python manage.py makemigrations
python manage.py migrate

echo ">> Collecting Static Files for Nginx..."
python manage.py collectstatic --noinput

echo ">> Configuring Gunicorn Systemd daemon..."
sudo bash -c "cat > /etc/systemd/system/gunicorn.service <<EOF
[Unit]
Description=Gunicorn daemon for AWS Django App
After=network.target

[Service]
User=$USER
Group=www-data
WorkingDirectory=$APP_DIR
ExecStart=$APP_DIR/venv/bin/gunicorn --access-logfile - --workers 3 --bind unix:$APP_DIR/app.sock core.wsgi:application

[Install]
WantedBy=multi-user.target
EOF"

echo ">> Configuring Nginx Proxy..."
sudo bash -c "cat > /etc/nginx/sites-available/django_app <<EOF
server {
    listen 80;
    server_name _;

    location = /favicon.ico { access_log off; log_not_found off; }
    
    location /static/ {
        alias $APP_DIR/static/;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:$APP_DIR/app.sock;
    }
}
EOF"

echo ">> Activating Nginx Site..."
sudo ln -sf /etc/nginx/sites-available/django_app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

echo ">> Booting Web Servers..."
# Stop any stale gunicorn instance (removes leftover socket file)
sudo systemctl stop gunicorn 2>/dev/null || true
# Remove leftover socket file if gunicorn crashed and left one behind
sudo rm -f "$APP_DIR/app.sock"
sudo systemctl daemon-reload
sudo systemctl start gunicorn
sudo systemctl enable gunicorn
sudo systemctl restart nginx
sudo systemctl enable nginx

echo ">> Fixing socket permissions for Nginx..."
# Wait briefly for gunicorn to create the socket, then lock down permissions
sleep 2
if [ -S "$APP_DIR/app.sock" ]; then
    sudo chmod 660 "$APP_DIR/app.sock"
    sudo chown $USER:www-data "$APP_DIR/app.sock"
    echo "   ✅ Socket permissions set correctly."
else
    echo "   ⚠️  WARNING: app.sock not found — Gunicorn may have failed to start."
    echo "   Run: sudo journalctl -u gunicorn -n 30 --no-pager"
fi

echo "======================================================"
echo " ✅ DEPLOYMENT 100% COMPLETE & LIVE!"
echo "======================================================"
echo "Your app is now running globally via Nginx on Port 80."
echo ""
echo ">> Final Health Check..."
GUNICORN_STATUS=$(sudo systemctl is-active gunicorn)
NGINX_STATUS=$(sudo systemctl is-active nginx)
echo "   Gunicorn : $GUNICORN_STATUS"
echo "   Nginx    : $NGINX_STATUS"
if [ "$GUNICORN_STATUS" != "active" ] || [ "$NGINX_STATUS" != "active" ]; then
    echo ""
    echo "  ⚠️  One or more services are NOT running. Debug with:"
    echo "     sudo journalctl -u gunicorn -n 30 --no-pager"
    echo "     sudo journalctl -u nginx -n 30 --no-pager"
else
    echo "   ✅ Both services are active. Your app is live!"
fi
echo ""
echo "If you need an admin account to login, run:"
echo "source venv/bin/activate && python manage.py createsuperuser"
