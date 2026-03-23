from flask import Flask, jsonify, request
import pymysql
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)

# Configure RDS database connection
def get_db_connection():
    try:
        connection = pymysql.connect(
            host=os.getenv('RDS_HOST', 'your-rds-endpoint.amazonaws.com'),
            user=os.getenv('RDS_USER', 'admin'),
            password=os.getenv('RDS_PASSWORD', 'password'),
            database=os.getenv('RDS_DB_NAME', 'testdb'),
            cursorclass=pymysql.cursors.DictCursor
        )
        return connection
    except pymysql.MySQLError as e:
        print(f"Error connecting to RDS: {e}")
        return None

@app.route('/')
def home():
    return jsonify({"message": "Welcome to the API deployed on EC2 connecting to RDS MySQL!"})

@app.route('/test-db', methods=['GET'])
def test_db():
    conn = get_db_connection()
    if conn is None:
        return jsonify({"status": "error", "message": "Failed to connect to RDS database."}), 500
    
    try:
        with conn.cursor() as cursor:
            # simple test query
            cursor.execute("SELECT VERSION()")
            result = cursor.fetchone()
        conn.close()
        return jsonify({
            "status": "success",
            "message": "Successfully connected to RDS!",
            "mysql_version": result
        })
    except Exception as e:
        if conn and conn.open:
            conn.close()
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    # Run application on 0.0.0.0 to allow access outside of EC2 localhost
    app.run(host='0.0.0.0', port=8000, debug=True)
