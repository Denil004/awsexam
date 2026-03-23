# Zero-Touch AWS EC2 + RDS Deployment 🚀

This repository is designed to be cloned onto **ANY fresh Ubuntu EC2 instance** and deployed against **ANY standard AWS RDS MySQL database** entirely automatically! It configures a complete resilient backend using Django, Gunicorn, Nginx, and PyMySQL out of the box.

## Instructions for ANY Server

### 1. Ready your AWS RDS Database
Ensure your RDS engine is running and you have created an initial, blank database (e.g., `CREATE DATABASE awsexam;`) securely via an admin connection.

### 2. Download code on your EC2 box
```bash
git clone https://github.com/albertcyriac04-lgtm/awsexam.git
cd awsexam
chmod +x deploy.sh
```

### 3. Deploy
Execute the completely automated deployment script:
```bash
./deploy.sh
```

**What the script automatically does:**
1. Dynamically detects your folder structure.
2. If this is your first time, it will pause, generate a `.env` template, and ask you to update your RDS credentials! (Update using `nano .env`)
3. Patches the strict security permissions blocking Nginx.
4. Generates an isolated Python Virtual Environment and automatically installs all dependencies (including `cryptography` for MySQL 8 Authentication bypasses!).
5. Generates the Python blueprint configurations via `makemigrations`.
6. Instantiates the tables into your AWS RDS database securely via `migrate`.
7. Hard-codes Nginx and Gunicorn configuration files tailored to your specific system environments.
8. Registers your web servers as background Linux systemd services and exposes Port 80.

### 4. Need an Admin Portal?
Once deployed successfully, manually launch the virtual environment and create an administrative user:
```bash
source venv/bin/activate
python manage.py createsuperuser
```
You can access your database management panel at `http://<your-ec2-ip>/admin/`.
