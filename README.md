# Small App for Ubuntu EC2 with RDS database

This is a minimum viable Flask application to verify connectivity between an AWS EC2 instance running Ubuntu (`ubuntu` user) and an AWS RDS MySQL database.

## Included Files

- `app.py`: Simple Flask API with an endpoint to test RDS connection.
- `.env.example`: Configuration variables needed for the connection.
- `requirements.txt`: Python package requirements.
- `deploy.sh`: Shell script to clone and set up the Python environment on your Ubuntu EC2 instance.

## Deployment Instructions

### 1. Launch RDS Instance
1. Launch an RDS MySQL Database.
2. Note your Endpoint name, Database Name, Username, and Password.
3. Make sure the RDS Security Group allows inbound MySQL traffic (`port 3306`) from the Security Group attached to your EC2 instance.

### 2. Launch EC2 Instance
1. Launch an **Ubuntu** EC2 instance.
2. Ensure you have internet access (e.g., public IP or NAT gateway).
3. Update the EC2 Security Group to allow inbound HTTP/TCP traffic on port `8000` (so you can view the response).

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

# Move files to application folder or run setup in the local directory
./deploy.sh
```

### 4. Configure Environment
1. Enter the application directory where the script deployed it. If using the script defaults: `cd /home/ubuntu/app`
2. Copy `.env.example` to `.env`: `cp .env.example .env`
3. Edit `.env` with your actual RDS credentials: `nano .env`

### 5. Run the Server
While the virtual environment is open, run:
```bash
source venv/bin/activate
python app.py
```
Visit `http://<ec2-public-ip>:8000/test-db` to verify the connection.
