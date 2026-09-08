from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, DoubleType
from pyspark.sql.functions import col

print("🚀 Initializing PySpark Engine with AWS S3 capabilities...")

# We must include the AWS packages so open-source Spark can talk to S3!
spark = SparkSession.builder \
    .appName("DataOps_Lakehouse_Pipeline") \
    .config("spark.jars.packages", "org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.262") \
    .config("spark.hadoop.fs.s3a.aws.credentials.provider", "com.amazonaws.auth.InstanceProfileCredentialsProvider") \
    .config("spark.hadoop.fs.s3a.endpoint", "s3.ap-south-1.amazonaws.com") \
    .getOrCreate()

RAW_BUCKET = "s3a://enterprise-dataops-dev-raw-be00c895"
CURATED_BUCKET = "s3a://enterprise-dataops-dev-curated-be00c895"

schema = StructType([
    StructField("transaction_id", StringType(), True),
    StructField("customer_id", StringType(), True),
    StructField("product_category", StringType(), True),
    StructField("amount", DoubleType(), True),
    StructField("payment_status", StringType(), True),
    StructField("timestamp", StringType(), True)
])

print(f"📡 Connecting to {RAW_BUCKET} using EC2 IAM VIP Badge...")

# 1. Bronze Layer (Ingest from S3 Raw)
bronze_df = (spark.readStream
    .format("json")
    .schema(schema)
    .load(f"{RAW_BUCKET}/raw_transactions/")
)

# 2. Silver Layer (Cleanse Data Quality)
silver_df = (bronze_df
    .filter(col("transaction_id").isNotNull())
    .filter(col("amount") > 0.0)
)

print(f"🌊 Streaming clean data as Parquet into {CURATED_BUCKET}...")

# 3. Curated Layer (Write to S3)
query = (silver_df.writeStream
    .format("parquet")
    .outputMode("append")
    .option("checkpointLocation", f"{CURATED_BUCKET}/checkpoints/silver_transactions")
    .start(f"{CURATED_BUCKET}/silver/transactions")
)

# Keep the stream running indefinitely!
query.awaitTermination()
