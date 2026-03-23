# Django App for Ubuntu EC2 with Nginx & RDS

This is a minimum viable **Django** backend configured with **Gunicorn** and **Nginx** to connect to an AWS RDS MySQL database asynchronously. 

## Included Tech Stack

- **Django**: The core web framework backend. 
- **PyMySQL**: Used to connect Django securely to MySQL (RDS configuration built-in).
- **Gunicorn**: The robust application server handling requests over a UNIX socket.
- **Nginx**: Serving as a reverse proxy forwarding requests to Gunicorn.
- **deploy.sh**: Script to set up all dependencies, systemd services, and Nginx configurations automatically securely without needing manual file manipulation.

## Deployment Instructions

### 1. Launch RDS Instance
1. Launch an RDS MySQL Database.
2. Note your Endpoint name, Database Name, Username, and Password.
3. Make sure the RDS Security Group allows inbound MySQL traffic (`port 3306`) from the Security Group attached to your EC2 instance.

### 2. Launch EC2 Instance
1. Launch an **Ubuntu** EC2 instance.
2. Ensure you have internet access (e.g., public IP or NAT gateway).
3. Update the EC2 Security Group to allow inbound HTTP/TCP traffic on port `80` (so Nginx can reach the public internet).

### 3. Deploy App
Connect via SSH:
```bash
ssh -i "your-key.pem" ubuntu@<your-ec2-ip-address>
```
Clone this repository to the Ubuntu instance:
```bash
git clone https://github.com/albertcyriac04-lgtm/awsexam.git
cd awsexam
chmod +x deploy.sh

# Run the deployment script to setup Nginx and Gunicorn daemon
./deploy.sh
```

### 4. Configure Environment
1. Enter the application directory (the script installs it in `/home/ubuntu/app`): 
```bash
cd /home/ubuntu/app
```
2. Copy `.env.example` to `.env`: `cp .env.example .env`
3. Edit `.env` with your actual RDS credentials: `nano .env`
4. Important: Set `DJANGO_SECRET_KEY` and `DEBUG=False` for production in your `.env`.

### 5. Finalize the Setup
Once the environment variables are active, restart your gunicorn service to register the new database settings and apply initial database migrations:
```bash
# Restart the Gunicorn service
sudo systemctl restart gunicorn

# Activate virtual environment
source venv/bin/activate

# Apply migrations
python manage.py makemigrations student
python manage.py migrate

# Create a superuser to access the admin panel
python manage.py createsuperuser
```
Visit `http://<ec2-public-ip>/api/students/` to interact with the Student REST API, or navigate to `/admin/` to use the Django admin panel.
