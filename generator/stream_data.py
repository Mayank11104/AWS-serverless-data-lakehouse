import time
import json
import random
import boto3
from datetime import datetime, timezone

# Uses EC2 Instance Profile for authentication — no hardcoded credentials needed
s3_client = boto3.client('s3', region_name='ap-south-1')

BUCKET_NAME = "enterprise-dataops-dev-raw-eba721c2"
RAW_PREFIX  = "raw_transactions/"

CATEGORIES = ["Electronics", "Apparel", "Home & Kitchen", "Books", "Beauty"]
STATUSES   = ["SUCCESS", "PENDING", "FAILED"]


def generate_mock_transaction(index):
    """
    Generates a realistic e-commerce transaction.
    Intentionally injects 5% corrupt records (null ID) and 5% negative amounts
    to simulate real-world data quality issues for the ETL pipeline to handle.
    """
    is_corrupt  = random.random() < 0.05
    is_negative = random.random() < 0.05

    return {
        "transaction_id":   None if is_corrupt else f"TXN-{random.randint(100000, 999999)}",
        "customer_id":      f"CUST-{random.randint(1000, 9999)}",
        "product_category": random.choice(CATEGORIES),
        "amount":           round(
                                random.uniform(-50.0, -5.0) if is_negative
                                else random.uniform(10.0, 1500.0), 2
                            ),
        "payment_status":   random.choice(STATUSES),
        "timestamp":        datetime.now(timezone.utc).isoformat()
    }


def stream_data_to_s3():
    print(f"🚀 Starting data ingestion stream → S3 bucket: {BUCKET_NAME}")
    idx = 0
    while True:
        try:
            data      = generate_mock_transaction(idx)
            file_name = f"{RAW_PREFIX}transaction_{int(time.time())}_{idx}.json"

            s3_client.put_object(
                Bucket=BUCKET_NAME,
                Key=file_name,
                Body=json.dumps(data)
            )

            print(f"[INGESTED] {file_name} | ₹{data['amount']} | {data['payment_status']}")
            idx += 1
            time.sleep(5)

        except Exception as e:
            print(f"❌ Upload failed: {str(e)}")
            time.sleep(10)


if __name__ == "__main__":
    stream_data_to_s3()
