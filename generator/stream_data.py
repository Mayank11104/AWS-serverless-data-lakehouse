import time
import json
import random
import boto3
from datetime import datetime, timezone
# Initialize the AWS S3 Client using default EC2 Instance Profile credentials safely
s3_client = boto3.client('s3', region_name='ap-south-1')

# I updated this to the bucket Terraform just created for you!
BUCKET_NAME = "enterprise-dataops-dev-raw-eba721c2"
RAW_PREFIX = "raw_transactions/"

categories = ["Electronics", "Apparel", "Home & Kitchen", "Books", "Beauty"]
statuses = ["SUCCESS", "PENDING", "FAILED"]

def generate_mock_transaction(index):
    """Generates realistic transaction logs with intentional financial anomalies."""
    # EY Audit Scenarios:
    # 1. 5% of records will have a null transaction_id (Corrupt entry)
    # 2. 5% of records will have a negative amount (Data quality anomaly)
    is_corrupt = random.random() < 0.05
    is_negative = random.random() < 0.05
    
    return {
        "transaction_id": None if is_corrupt else f"TXN-{random.randint(100000, 999999)}",
        "customer_id": f"CUST-{random.randint(1000, 9999)}",
        "product_category": random.choice(categories),
        "amount": round(random.uniform(-50.0, -5.0) if is_negative else random.uniform(10.0, 1500.0), 2),
        "payment_status": random.choice(statuses),
        "timestamp": datetime.now(timezone.utc).isoformat()
    }

def stream_data_to_s3():
    print(f"🚀 Starting automated enterprise data ingestion to S3: {BUCKET_NAME}...")
    idx = 0
    while True:
        try:
            data = generate_mock_transaction(idx)
            file_name = f"{RAW_PREFIX}transaction_{int(time.time())}_{idx}.json"
            
            # Stream the raw JSON object directly into your S3 raw landing zone
            # Pro-Tip: In real production systems, you'd batch these into larger files,
            # but for our Databricks Autoloader demo, one file per tick is perfect!
            s3_client.put_object(
                Bucket=BUCKET_NAME,
                Key=file_name,
                Body=json.dumps(data)
            )
            
            print(f"[INGESTED] File: {file_name} | Amount: {data['amount']} | Status: {data['payment_status']}")
            idx += 1
            
            # Pause 5 seconds to simulate streaming tick data
            time.sleep(5)
            
        except Exception as e:
            print(f"❌ Error uploading log stream to AWS S3: {str(e)}")
            time.sleep(10)

if __name__ == "__main__":
    stream_data_to_s3()
